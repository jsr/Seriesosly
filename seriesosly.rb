require 'rubygems'
require 'sinatra/base'

module Seriesosly
	class Service < Sinatra::Base 
		configure do 
			set :app_file, __FILE__
			set :run, Proc.new {app_file == $0}
			set :environment, :development
		end 

		class << self 
			def run!(options={})
				init 
				super 
			end 

			def init 
				puts "Hello!"
			end 
		end 


		get '/' do 
			"Hello!"
		end 


		at_exit { run! if $!.nil? and run? }

	end 
end 
