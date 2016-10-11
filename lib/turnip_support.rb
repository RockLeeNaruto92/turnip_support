require "google_drive"
require "pry"
require "#{Dir.pwd}/lib/constants.rb"

# ---------------------------------------------------------------------------------- #
def valid_data?
  if missing_require_gem?
    @message_code = :dependency_gem_is_missing
    return
  end

  case ARGV.length
  when 1 # ruby lib/turnip_support.rb --init
    if ARGV[0] == "--init"
      @message_code = :init_env_completed
      return true
    end
    @message_code = :command_usage_is_wrong
    false
  when 2 # ruby lib/turnip_support.rb feature_name config_file
    unless !ARGV[1].nil? && File.exist?("#{Dir.pwd}/spec/configs/#{ARGV[1]}")
      @message_code = :config_file_is_not_exist
      return false
    end
    @message_code = :generate_completed
    true
  else
    @message_code = :command_usage_is_wrong
    false
  end
end

def messages_error message_code
  puts "\n#{ERROR_MESSAGES[message_code]}"
end

def main_process
  case @message_code
  when :init_env_completed
    initialize_environment
  when :generate_completed
    set_agruments
    @worksheet ||= initialize_worksheet @worksheet_order_number, @spreadsheet_key, @config_json_file
    read_feature_informations
    read_test_data_informations
    read_procedure_informations
    generate_feature_file
  end

  messages_error @message_code
end

def set_agruments
  require "#{Dir.pwd}/spec/google_drive_helper.rb"

  @feature_name = ARGV[0]
  @config_file = ARGV[1]
  read_config_data SPEC_CONFIG_JSON_FOLDER + @config_file
end

# ---------------------------------------------------------------------------------- #
def missing_require_gem?
  DEPENDENCY_GEMS.each do |gem_name|
    return true unless system "bundle show #{gem_name}"
  end
  false
end

# ---------------------------------------------------------------------------------- #
# Init the environment: tunrip_helper.rb,
def initialize_environment
  turnip_helper_file_path = SPEC_FOLDER + "turnip_helper.rb"
  File.open(turnip_helper_file_path, "a"){|f| f.write CONFIG_CONTENT}
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

  # create and put code to feature_name.feature
  put_code_to_file @feature_name, content, true
end

# ---------------------------------------------------------------------------------- #
# Put code to file
# Crete feature_name.feature with content is content
def put_code_to_file feature_name, content, overwrite = false
  file_path = SPEC_FEATURE_FOLDER + feature_name + FEATURE_EXTESION
  return if File.exist?(file_path) && !overwrite

  File.open(file_path, "w"){|f| f.write content}
  puts "Complete writing code to #{file_path}"
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

valid_data?
main_process
