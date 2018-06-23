# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'

require_relative 'testapp'

Dir.foreach('test/') do |test|
	next if ['.', '..'].include? test
	require_relative test
end
