Gem::Specification.new do |s|
  s.name = "turnip_support"
  s.version = "1.0.0"
  s.authors = ["Bui Minh thu"]
  s.email = ["minhthu@temona.co.jp"]
  s.homepage = "https://github.com/ThuBM/turnip-support"
  s.summary = "TurnipSupport"
  s.description = "This gem supports testing Rails Application using turnip and headless browser(poltergist)"
  s.license = "MIT"

  s.files = ["lib/helpers/code_generator_helper.rb",
    "lib/helpers/google_drive_helper.rb",
    "lib/spec/steps/basic_steps.rb",
    "lib/turnip_support.rb",
    "lib/turnip_constants.rb",
    "lib/tasks/turnip_support.rake",
    "lib/turnip_support/railtie.rb",
    "lib/turnip_support/google_drive_instance.rb",
    "lib/templates/custom_steps.rb",
    "lib/templates/turnip_helper.rb"
  ]

  s.add_dependency "google_drive"
  s.add_dependency "rails"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "turnip"
  s.add_development_dependency "capybara"
  s.add_development_dependency "capybara-screenshot"
  s.add_development_dependency "poltergeist"
  s.add_development_dependency "pry"
  s.add_development_dependency "activesupport"
end
