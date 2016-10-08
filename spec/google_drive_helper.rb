require "google_drive"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
CURRENT_MODE = [:actions, :results]

def initialize_session config_json_path
  GoogleDrive::Session.from_config(config_json_path)
end

def initialize_speadsheet_session key, config_json_path
  @session ||= initialize_session config_json_path
  @session.spreadsheet_by_key(key)
end

def initialize_worksheet order_num, key, config_json_path
  @spreadsheet ||= initialize_speadsheet_session key, config_json_path
  @spreadsheet.worksheets[order_num]
end

def is_empty_row? worksheet, iterator
  (1..worksheet.num_cols).each do |col|
    return false unless worksheet[iterator, col].empty?
  end
  true
end

# return the hash contains feature's informations of test file with 3 informations: feature_name, backlog link, and status
# example:
#   {
#     feature_name: "ログイン機能",
#     backlog_link: "https://temona.backlog.jp",
#     status: "未確認"
#   }
def get_feature_informations worksheet
  feature_name = worksheet[1, 2]
  backlog_link = worksheet[2, 2]
  status = worksheet[3, 2]

  {
    feature_name: feature_name,
    backlog_link: backlog_link,
    status: status
  }
end

# return the hash contains test data's informations of test file.
# example:
#   {
#     start_row: integer,
#     last_row: integer
#   }
def get_test_data_informations worksheet
  start_row = 6
  last_row = 6

  while !is_empty_row? worksheet, last_row do
    last_row += 1
  end

  {
    start_row: start_row,
    last_row: last_row - 1
  }
end

# return the hash contains test data's informations of test file.
# example:
#   {
#     1 => {
#       start_row: 31,
#       scenario_name: "system_adminとしてログイン",
#       actions: {
#         1 => {start_row: 35, last_row: 35},
#         2 => {start_row: 36, last_row: 36},
#         ...
#       },
#       results: {
#         1 => {start_row: 42, last_row: 48},
#         2 => {start_row: 49, last_row: 49},
#         ...
#       },
#       last_row: 53
#     },
#     2 => {
#       ...
#     }
#   }
def get_procedure_informations worksheet, start_row
  hash = Hash.new
  proc_index = 0
  proc_data = nil
  branch_index = 0
  branch_data = nil
  last_row = start_row

  # current_mode:
  #   :actions if reading actions
  #   :results if reading expect_results
  current_mode = :actions

  while last_row <= worksheet.num_rows do
    if is_empty_row? worksheet, last_row
      current_mode = (CURRENT_MODE - [current_mode])[0]
      branch_index = 0
      last_row += 1

      branch_data[:last_row] = last_row - 2
      if current_mode == :actions
        proc_data[:last_row] = last_row - 2
      end
      next
    end

    unless worksheet[last_row, 1].empty?
      proc_index += 1
      proc_data = Hash.new
      proc_data[:start_row] = last_row
      proc_data[:scenario_name] = worksheet[last_row, 2]
      proc_data[:actions] = Hash.new
      proc_data[:results] = Hash.new
      hash[proc_index] = proc_data
    end

    unless worksheet[last_row, 3].empty?
      branch_index += 1
      branch_data[:last_row] = last_row - 1 unless branch_data.nil? || !branch_data[:last_row].nil?
      branch_data = Hash.new
      branch_data[:start_row] = last_row
      proc_data[current_mode][branch_index] = branch_data
    end

    last_row += 1
  end

  branch_data[:last_row] = last_row - 1
  proc_data[:last_row] = last_row - 1
  hash
end
