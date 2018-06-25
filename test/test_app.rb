# frozen_string_literal: true

require_relative '../lib/woah'

class TestApp < Woah::Base
	before do
		@a = 'chunky'
	end

	on '/' do
		'hi there!'
	end

	on '/', 'POST' do
		'got post!'
	end

	on '/before' do
		@a
	end

	on '/after' do
		@b
	end

	after do
		@b = 'bacon'
	end
end