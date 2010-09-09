$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'fepfile'
require 'spec'
require 'spec/autorun'
require 'support/extensions/array'

# require "test/unit"
# include Test::Unit::Assertions

Spec::Runner.configure do |config|
  
end
