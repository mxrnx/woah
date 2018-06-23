# frozen_string_literal: true

require_relative '../lib/woah'

class TestApp < Woah::Base
	before do
		@@time = 'chunky'
	end

	on '/' do
		'hi there!'
	end

	on '/', 'POST' do
		'got post!'
	end

	on '/before_after' do
		@@time
	end

	after do
		@@time = 'bacon'
	end

	def self.time
		@@time
	end
end
