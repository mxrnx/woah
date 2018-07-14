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

	on '/get_cookie' do
		cookie 'test'
	end

	on '/set_cookie' do
		cookie 'fruit', 'apple'
	end

	on '/set_illegal_cookie' do
		cookie 'one', 1
	end

	on '/delete_cookie' do
		cookie 'foo', :delete
	end

	on '/ip' do
		request.env['REQUEST_URI']
	end

	TestApp.on '/nose' do
		TestApp.set :nose, true
	end

	after do
		@b = 'bacon'
	end
end
