Dir[File.join(File.dirname(__FILE__), "aws_cost_calculator/*.rb")].sort.each { |lib| require "#{lib}" }

@base_dir = File.expand_path(File.dirname(__FILE__)) + "/../"
