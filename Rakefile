# frozen_string_literal: true

require 'rake/testtask'

task default: %w[test style]

task :test do
  ruby 'test/test_helper.rb'
end

task :style do
  sh 'rubocop -c .rubocop.yml lib/ test/ Gemfile Rakefile woah.gemspec'
end
