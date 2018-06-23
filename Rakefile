# frozen_string_literal: true

require 'rake/testtask'

task default: %w[run]

task :test do
	ruby 'test/test_helper.rb'
end

task :style do
	sh 'rubocop -c .rubocop.yml examples/ lib/ test/ Gemfile Rakefile woah.gemspec'
end
