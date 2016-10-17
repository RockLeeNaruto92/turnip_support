require "google_drive"
require "active_support/concern"

module CodeGeneratorHelper
  extend ActiveSupport::Concern

  class_methods do
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

    # Put code to file
    # Crete feature_name.feature with content is content
    def put_code_to_file feature_name, content, overwrite = false
      file_path = SPEC_FEATURE_FOLDER + feature_name + FEATURE_EXTESION
      return if File.exist?(file_path) && !overwrite

      unless File.exist? SPEC_FEATURE_FOLDER
        system "mkdir -p #{SPEC_FEATURE_FOLDER}"
      end

      File.open(file_path, "w"){|f| f.write content}
      puts "Complete writing code to #{file_path}"
    end

    # Generate feature code
    def generate_feature_code
      return "" if @feature_data.nil?

      <<-EOS
    Feature: #{@feature_data[:feature_name]}
      EOS
    end

    # Generate test data creation code
    def generate_test_data_creation_code
      return "" if @test_data.nil?

      <<-EOS
      Background:
        Given set config file: "#{@config_file}"
        And create test data from row "#{@test_data[:start_row]}" to "#{@test_data[:last_row]}"
      EOS
    end

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
  end
end
