require "turnip_constants.rb"
require "helpers/google_drive_helper"
require "helpers/code_generator_helper"
require "google_drive"

module TurnipSupport
  require "turnip_support/railtie" if defined?(Rails)

  class TurnipSupport
    include CodeGeneratorHelper
    include GoogleDriveHelper

    class << self
      def valid_data? params
        case params.length
        when 1 # ruby lib/turnip_support.rb --init
          if params[0] == "--init"
            @message_code = :init_env_completed
            return true
          end
          @message_code = :command_usage_is_wrong
          false
        when 2 # ruby lib/turnip_support.rb feature_name config_file
          unless !params[1].nil? && File.exist?("#{Dir.pwd}/spec/configs/#{params[1]}")
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

        @feature_name = params[0]
        @config_file = params[1]
        read_config_data SPEC_CONFIG_JSON_FOLDER + @config_file
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
    end
  end
end
