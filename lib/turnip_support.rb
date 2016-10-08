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

  @feature_name = ARGV[0]
  @config_file = ARGV[1]
  read_config_data SPEC_CONFIG_JSON_FOLDER + @config_file
  true
end

def messages_error message_code
  puts "\n#{ERROR_MESSAGES[message_code]}"
end

# ---------------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------------- #
# Read config data
def read_config_data config_file_path
  hash = YAML.load(File.read config_file_path)

  @worksheet_order_number = hash["worksheet_order_number"]
  @spreadsheet_key = hash["spreadsheet_key"]
  @config_json_file = SPEC_CONFIG_JSON_FOLDER + hash["config_file"]
end

# ---------------------------------------------------------------------------------- #
# Read data from spreadsheet_key
def read_feature_informations
  @feature_data = get_feature_informations @worksheet
  puts "Completed reading feature informations and saved to @feature_data!"
end

def read_test_data_informations
  @test_data = get_test_data_informations @worksheet
  puts "Completed reading test data and saved to @test_data!"
end

def read_procedure_informations
  return unless @test_data
  start_row = @test_data[:last_row] + 3
  @procedures_data = get_procedure_informations @worksheet, start_row
  puts "Completed reading procedure informations and saved to @procedures_data!"
end

# ---------------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------------- #
# Generate feature file
def generate_feature_file
  return unless @procedures_data

  content = <<-EOS
# encoding: utf-8

  EOS

  content += generate_feature_code
  content += generate_test_data_creation_code
  content += generate_scenarios_code
  puts content
end

# ---------------------------------------------------------------------------------- #
# Generate feature code
def generate_feature_code
  return "" if @feature_data.nil?

  <<-EOS
Feature: #{@feature_data[:feature_name]}
  EOS
end

# ---------------------------------------------------------------------------------- #
# Generate test data creation code
def generate_test_data_creation_code
  return "" if @test_data.nil?

  <<-EOS
  Background:
    Given set config file: "#{@config_file}"
    And create test data from row "#{@test_data[:start_row]}" to "#{@test_data[:last_row]}"
  EOS
end

# ---------------------------------------------------------------------------------- #
# Generate scenarios code
def generate_scenarios_code
  return "" if @procedures_data.nil?
  content = ""

  @procedures_data.each do |_, proc_data|
    content += <<-EOS

  Scenario: #{proc_data[:scenario_name]}
    EOS

    common_last_row = proc_data[:actions][1][:start_row] - 1
    if common_last_row > proc_data[:start_row]
      content += <<-EOS
    Given do actions from row "#{proc_data[:start_row]}" to "#{common_last_row}"
      EOS
    end

    proc_data[:actions].each do |key, action_data|
      expect_data = proc_data[:results][key]
      content += <<-EOS
    When do actions from row "#{action_data[:start_row]}" to "#{action_data[:last_row]}"
    Then expect result from row "#{expect_data[:start_row]}" to "#{expect_data[:last_row]}"
      EOS
    end
  end

  content
end

# ---------------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------------- #
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
