require File.join(File.dirname(__FILE__), '..', 'seriesosly.rb')

require 'rspec'
require 'rack/test'

set :environment, :test 

RSpec.configure do |conf| 
	conf.include Rack::Test::Methods
end 

def app
	Sinatra::Application
end 
