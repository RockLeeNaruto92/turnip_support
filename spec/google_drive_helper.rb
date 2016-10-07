require "google_drive"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

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
  @worksheet ||= initialize_worksheet order_num, key, config_json_path

  feature_name = worksheet[1, 2]
  backlog_link = worksheet[2, 2]
  status = worksheet[3, 2]

  {
    feature_name: feature_name,
    backlog_link: backlog_link,
    status: status
  }
end
