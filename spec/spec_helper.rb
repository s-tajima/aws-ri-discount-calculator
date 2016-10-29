require 'rspec'

Dir[File.join(File.dirname(__FILE__), "..", "lib", "**/*.rb")].each{|f| require f }

RSpec.configure do |config|
  config.color     = true
  config.tty       = true
  config.formatter = :documentation
end
