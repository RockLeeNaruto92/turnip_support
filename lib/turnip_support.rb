require "google_drive"
require "pry"

# define constant
ERROR_MESSAGES = {
  config_file_is_not_exist: "The config json file is not existed! This file must be placed at #{Dir.pwd}/spec/configs/ folder!",
  command_usage_is_wrong: "Usage: \truby lib/turnip_support.rb [feature] [config_file]",
  completed: "Completed!"
}
SPEC_CONFIG_JSON_FOLDER = "#{Dir.pwd}/spec/configs/"
SPEC_FEATURE_FOLDER = "#{Dir.pwd}/spec/features/"

def valid_data?
  unless ARGV.length == 2
    @message_code = :command_usage_is_wrong
    return false
  end

  unless !ARGV[1].nil? && File.exist?("#{Dir.pwd}/spec/configs/#{ARGV[1]}")
    @message_code = :config_file_is_not_exist
    return false
  end

  require "#{Dir.pwd}/spec/google_drive_helper.rb"

  read_config_data SPEC_CONFIG_JSON_FOLDER + ARGV[1]
  true
end

def messages_error message_code
  puts "\n#{ERROR_MESSAGES[message_code]}"
end

# ------------------------------------------------------- #
# Read config data
def read_config_data config_file_path
  hash = YAML.load(File.read config_file_path)

  @worksheet_order_number = hash["worksheet_order_number"]
  @spreadsheet_key = hash["spreadsheet_key"]
  @config_json_file = SPEC_CONFIG_JSON_FOLDER + hash["config_file"]
end

# ------------------------------------------------------- #
# Read data from spreadsheet_key
def read_feature_informations
  # TODO
  @feature_data = get_feature_informations @worksheet
  puts "Completed reading feature informations and saved to @feature_data!"
end

def read_test_data_informations
  # TODO
  puts "Completed reading test data and saved to @test_data!"
end

def read_procedure_informations
  # TODO
  puts "Completed reading procedure informations and saved to @procedures_data!"
end

# ------------------------------------------------------- #
# Generate feature file
def generate_feature_file
  # TODO
end

# ------------------------------------------------------- #
# ------------------------------------------------------- #
# main process

if valid_data?
  @worksheet ||= initialize_worksheet @worksheet_order_number, @spreadsheet_key, @config_json_file

  read_feature_informations
  read_test_data_informations
  read_procedure_informations
  generate_feature_file

  @messages_error = :completed
end

messages_error @message_code
