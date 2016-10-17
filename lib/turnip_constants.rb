COMMAND_USAGE = <<-EOS
Usage:
  ruby lib/turnip_support.rb [feature] [config_file]
or
  ruby lib/turnip_support.rb --init
EOS

CONFIG_CONTENT = <<-EOS
require "turnip"
require "turnip/capybara"
require "turnip/rspec"
require "capybara"
require "capybara-screenshot/rspec"
require "pry"
require "capybara/poltergeist"
require "rails_helper"

# turnip_support configuration
Dir.glob("spec/steps/**/*steps.rb"){|f| load f, true}

Capybara::Screenshot.class_eval do
    register_driver(:poltergeist) do |driver, path|
      driver.render(path, :full => true)
    end
end

Capybara::Screenshot.autosave_on_failure = true

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app, js_errors: true, default_wait_time: 30, timeout: 100,
    phantomjs_logger: STDOUT,
    phantomjs_options: [
      '--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=any'
  ])
end

Capybara.configure do |config|
  config.default_driver = :poltergeist
  config.javascript_driver = :poltergeist
  config.ignore_hidden_elements = true
  config.default_wait_time = 20
end

Capybara.run_server = true
Capybara.server_port = 3000
Capybara.app_host = "http://127.0.0.1:3000"

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
EOS

MISSING_GEM_ERROR = <<-EOS
Please install all of below gems:
  - rspec-rails :         https://github.com/rspec/rspec-rails
  - turnip :              https://github.com/jnicklas/turnip
  - capybara :            https://github.com/jnicklas/capybara
  - capybara-screenshot : https://github.com/mattheworiordan/capybara-screenshot
  - poltergeist :         https://github.com/teampoltergeist/poltergeist
  - factory_girl_rails :  https://github.com/thoughtbot/factory_girl_rails
  - google_drive :        https://github.com/gimite/google-drive-ruby
EOS

DEPENDENCY_GEMS = ["rspec-rails", "turnip", "capybara", "capybara-screenshot",
  "poltergeist", "factory_girl_rails", "google_drive"]

ERROR_MESSAGES = {
  config_file_is_not_exist: "The config json file is not existed! This file must be placed at #{Dir.pwd}/spec/configs/ folder!",
  command_usage_is_wrong: COMMAND_USAGE,
  generate_completed: "Generate code is completed!",
  init_env_completed: "Initialize environment is completed!",
  dependency_gem_is_missing: MISSING_GEM_ERROR
}
SPEC_CONFIG_JSON_FOLDER = "#{Dir.pwd}/spec/configs/"
SPEC_FEATURE_FOLDER = "#{Dir.pwd}/spec/features/"
SPEC_FOLDER = "#{Dir.pwd}/spec/"
FEATURE_EXTESION = ".feature"
