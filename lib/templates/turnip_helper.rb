require "turnip"
require "turnip/capybara"
require "turnip/rspec"
require "capybara"
require "capybara-screenshot/rspec"
require "pry"
require "capybara/poltergeist"
require "rails_helper"
require "spec_helper"

# turnip_support configuration
# load all steps file of your project
Dir.glob("spec/steps/**/*steps.rb"){|f| load f, true}

# load basic_steps.rb
gem_path = Gem.loaded_specs['turnip_support'].full_gem_path
load "#{gem_path}/lib/spec/steps/basic_steps.rb"


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
