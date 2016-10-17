require "turnip_support/railtie" if defined?(Rails)
require "turnip_constants.rb"
require "helpers/google_drive_helper"
require "helpers/code_generator_helper"
require "google_drive"
require "rails"

module TurnipSupport
  class TurnipSupport
    include CodeGeneratorHelper
    include GoogleDriveHelper

    class << self
      # validate input data
      def valid_data? params
        case params.length
        when 2 # ruby lib/turnip_support.rb --init
          if params[1] == "init"
            @message_code = :init_env_completed
            return true
          end
          @message_code = :command_usage_is_wrong
          false
        when 3 # ruby lib/turnip_support.rb feature_name config_file
          unless !params[2].nil? && File.exist?("#{Dir.pwd}/spec/configs/#{params[1]}")
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

      # Puts the message of error
      def messages_error message_code
        puts "\n#{ERROR_MESSAGES[message_code]}"
      end

      #
      def set_agruments
        @feature_name = params[0]
        @config_file = params[1]
        read_config_data SPEC_CONFIG_JSON_FOLDER + @config_file
      end

      # Init the environment: tunrip_helper.rb,
      def initialize_environment
        system "bundle exec rails generate rspec:install"

        # config turnip_helper.rb
        turnip_helper_file_path = SPEC_FOLDER + "turnip_helper.rb"
        File.open(turnip_helper_file_path, "a"){|f| f.write CONFIG_CONTENT}

        # copy basic_steps.rb
        custom_steps_file_path = SPEC_FOLDER + "steps/custom_steps.rb"
        File.open(custom_steps_file_path, "a"){|f| f.write CUSTOM_STEPS_CONTENT}
      end

      # Read config data
      def read_config_data config_file_path
        hash = YAML.load(File.read config_file_path)

        @worksheet_order_number = hash["worksheet_order_number"]
        @spreadsheet_key = hash["spreadsheet_key"]
        @config_json_file = SPEC_CONFIG_JSON_FOLDER + hash["config_file"]
      end

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

      # ----------------------------------------------------------------------------- #
      # Main flow
      def main_process
        case @message_code
        when :init_env_completed
          initialize_environment
        when :generate_completed
          set_agruments
          @worksheet ||= initialize_worksheet @worksheet_order_number,
            @spreadsheet_key, @config_json_file
          read_feature_informations
          read_test_data_informations
          read_procedure_informations
          generate_feature_file
        end

        messages_error @message_code
      end
    end
  end
end
