require "turnip_support"

desc "Run as the main process of turnip support"
task :turnip_support do
  ARGV.each { |a| task a.to_sym do ; end }

  TurnipSupport::TurnipSupport.valid_data? ARGV
  TurnipSupport::TurnipSupport.main_process ARGV
end
