COMMAND_USAGE = <<-EOS
Usage:
  ruby lib/turnip_support.rb [feature] [config_file]
or
  ruby lib/turnip_support.rb --init
EOS

CONFIG_CONTENT = File.open("#{File.dirname(__FILE__)}/templates/turnip_helper.rb", "r"){|f| f.read}
CUSTOM_STEPS_CONTENT = File.open("#{File.dirname(__FILE__)}/templates/custom_steps.rb", "r"){|f| f.read}

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
