require "rails"
require "turnip_support"

module TurnipSupport
  class Railtie < ::Rails::Railtie
    railtie_name :turnip_support

    rake_tasks do
      load "tasks/turnip_support.rake"
    end
  end
end
