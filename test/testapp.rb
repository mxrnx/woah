require_relative '../lib/woah'

class TestApp < Woah::Base
	on '/' do
		'hi there!'
	end

	before do
		@@time = 'chunky'
	end

	on '/before_after' do
		@@time
	end

	after do
		@@time = 'bacon'
	end

	def self.get_time
		@@time
	end
end
