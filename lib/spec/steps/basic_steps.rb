# coding: utf-8

require "#{File.dirname(__FILE__)}/../../turnip_support/google_drive_instance.rb"

# test data
DEFAULT_MODEL_NAME_COL = "B"
DEFAULT_OBJ_ID_COL = "D"
DEFAULT_OBJ_ATTR_START_COL = "E"
DEFAULT_ACTION_NAME_COL = "D"
DEFAULT_ACTION_PARAMS_START_COL = "E"
DEFAULT_EXPECT_METHOD_NAME = "D"
DEFAULT_EXPECT_PARAMS_START_COL = "E"
DEFAULT_RESULT_COL = "I"
DEFAULT_IMAGE_COL = "J"
DEFAULT_RESULT_MESSAGE_OK = "OK"
DEFAULT_RESULT_MESSAGE_NG = "NG"
CAPYBARA_IMAGE_FOLDER = "#{Rails.root}/tmp/capybara/"
CONFIGS_FOLDER = "#{Rails.root}/spec/configs/"

step "set config file: :config_file" do |config_file|
  path = CONFIGS_FOLDER + config_file
  hash = YAML.load(File.read path)

  @worksheet_order_number = hash["worksheet_order_number"]
  @spreadsheet_key = hash["spreadsheet_key"]
  @config_file = CONFIGS_FOLDER + hash["config_file"]

  @model_name_col = (hash["model_name_col"] || DEFAULT_MODEL_NAME_COL).ord - "A".ord + 1
  @obj_id_col = (hash["obj_id_col"] || DEFAULT_OBJ_ID_COL).ord - "A".ord + 1
  @obj_attr_start_col = (hash["obj_attr_start_col"] || DEFAULT_OBJ_ATTR_START_COL).ord - "A".ord + 1
  @action_name_col = (hash["action_name_col"] || DEFAULT_ACTION_NAME_COL).ord - "A".ord + 1
  @action_params_start_col = (hash["action_params_start_col"] || DEFAULT_ACTION_PARAMS_START_COL).ord - "A".ord + 1
  @expect_method_name = (hash["expect_method_name"] || DEFAULT_EXPECT_METHOD_NAME).ord - "A".ord + 1
  @expect_params_start_col = (hash["expect_params_start_col"] || DEFAULT_EXPECT_PARAMS_START_COL).ord - "A".ord + 1
  @result_col = (hash["result_col"] || DEFAULT_RESULT_COL).ord - "A".ord + 1
  @image_col = (hash["image_col"] || DEFAULT_IMAGE_COL).ord - "A".ord + 1
  @ok_msg = hash.try(:[], "result_message").try(:[], "ok") || DEFAULT_RESULT_MESSAGE_OK
  @ng_msg = hash.try(:[], "result_message").try(:[], "ng") || DEFAULT_RESULT_MESSAGE_NG
end

step "initalize worksheet" do
  @worksheet ||= TurnipSupport::GoogleDriveInstance.initialize_worksheet @worksheet_order_number,
    @spreadsheet_key, @config_file
end

# TEST DATA
step "create test data from row :row_start to :row_end" do |row_start, row_end|
  send "custom_init_data"

  row_start = row_start.to_i
  row_end = row_end.to_i

  send "initalize worksheet"
  # read and create init data
  model_name = nil
  temp = nil
  attr_names = Array.new
  attr_values = Hash.new

  (row_start..row_end).each do |row|
    temp = @worksheet[row, @model_name_col]
    if temp.present?
      model_name = temp
      # read all attr names of new object
      attr_names.clear
      (@obj_attr_start_col..@worksheet.num_cols).each do |col|
        attr_name = @worksheet[row, col]
        attr_names.push attr_name if attr_name.present?
      end
      next
    end

    # read attr values
    attr_values = {id: @worksheet[row, @obj_id_col]}
    attr_names.each_with_index do |attr, index|
      attr_values[attr] = @worksheet[row, @obj_attr_start_col + index]
    end

    # create data in here
    FactoryGirl.create model_name.underscore, attr_values
  end
end

# DO ACTIONS
step "do actions from row :row_start to :row_end" do |row_start, row_end|
  row_start = row_start.to_i
  row_end = row_end.to_i

  send "initalize worksheet"
  # read and process each rows
  data = Array.new
  (row_start..row_end).each do |row|
    action_name = @worksheet[row, @action_name_col]
    data.clear
    (@action_params_start_col..@worksheet.num_cols).each do |col|
      data.push @worksheet[row, col]
    end

    send "do action :action_name with data :data", action_name, data.to_s
  end
end

# EXPECT RESULT
step "expect result from row :row_start to :row_end" do |row_start, row_end|
  send "initialize screenshot folder"

  row_start = row_start.to_i
  row_end = row_end.to_i

  # read and process each rows
  send "initalize worksheet"

  scenario_result = true
  data = Array.new
  (row_start..row_end).each do |row|
    method_name = @worksheet[row, @expect_method_name]
    data.clear
    (@expect_params_start_col..@worksheet.num_cols).each do |col|
      data.push @worksheet[row, col]
    end

    result = send "expect result :method_name with :data", method_name, data.to_s
    unless [true, false].include? result
      scenario_result = false
      screenshot = Capybara::Screenshot.screenshot_and_save_page
      @worksheet[row, @image_col] = screenshot[:image]
    end

    # update spread sheet
    send "update result at row :row with result :result", row, result
  end

  raise RSpec::Expectations::ExpectationNotMetError unless scenario_result
end

#
step "update result at row :row with result :result" do |row, result|
  message = [true, false].include?(result) ? @ok_msg : @ng_msg
  @worksheet[row, @result_col] = message
  @worksheet.save
  @worksheet.reload
end

#
step "do action :action_name with data :data" do |action_name, data|
  data = eval(data)
  case action_name
  when "visit"
    visit data[0]
  when "click_link"
    click_link data[0]
  when "click_button"
    click_button data[0]
  when "click_on"
    click_on data[0]
  when "fill_in"
    fill_in data[0], with: data[1]
  when "choose"
    choose data[0]
  when "check"
    check data[0]
  when "uncheck"
    uncheck data[0]
  when "attack_file"
    attack_file data[0], data[1]
  when "select"
    select data[0], from: data[1]
  when "execute_script"
    page.execute_script data[0]
  when "custom_action"
    custom_action_name, *custom_action_data = data
    send custom_action_name, custom_action_data.to_s
  end
end

#
step "expect result :method_name with :data" do |method_name, data|
  data = eval(data)
  begin
    case method_name
    when "have_current_path"
      page.current_url == data[0]
    when "have_selector"
      return expect(page).to have_selector data[0] unless data[1].present?
      object = find("#{data[0]}") rescue nil
      return false if object.nil?
      expect(object).to have_content data[1]
    when "have_xpath"
      expect(page).to have_xpath data[0]
    when "have_css"
      expect(page).to have_css data[0]
    when "have_content"
      expect(page).to have_content data[0]
    when "raise_error"
      expect(page).to have_selector "section.backtrace"
    when "no_have_current_path"
      page.current_url != data[0]
    when "no_have_selector"
      return expect(page).not_to have_selector(data[0]) unless data[1].present?
      object = find("#{data[0]}") rescue nil
      return true if object.nil?
      expect(object).not_to have_content data[1]
    when "no_have_xpath"
      expect(page).not_to have_xpath data[0]
    when "no_have_css"
      expect(page).not_to have_css data[0]
    when "no_have_content"
      expect(page).not_to have_content data[0]
    when "no_raise_error"
      expect(page).not_to have_selector "section.backtrace"
    when "custom_expect"
      custom_method_name, *custom_result_data = data
      send custom_method_name, custom_result_data.to_s
    end
  rescue Exception => e
    e
  end
end

step "initialize screenshot folder" do
  unless File.exist? CAPYBARA_IMAGE_FOLDER
    system "mkdir -p #{CAPYBARA_IMAGE_FOLDER}"
  end
end
