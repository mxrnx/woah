# frozen_string_literal: true

require 'rake'
require_relative 'lib/woah/version'

Gem::Specification.new do |s|
  s.name = 'woah'
  s.version = Woah::VERSION
  s.platform = Gem::Platform::RUBY
  s.license = 'GPL-3.0'
  s.summary = 'Woah! is a minimal web framework built on Rack.'
  s.description = 'Woah! is a minimal web framework built on Rack designed to
  let you just do your thing.'
  s.author = 'knarka'
  s.email = 'knarka@airmail.cc'
  s.homepage = 'https://github.com/knarka/woah'

  s.add_dependency 'rack', '= 2.2.3.1'
  s.required_ruby_version = '>= 2.5.5'

  s.files = %w[LICENSE README.md] + Dir.glob('{lib,test}/**/*')

  s.require_path = 'lib'
end
