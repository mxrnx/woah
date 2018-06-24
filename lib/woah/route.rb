# frozen_string_literal: true

module Woah
	# Holds Woah! routes
	class Route
		attr_accessor :match_data

		def initialize(path, method, &action)
			raise 'only strings and regexps are valid paths' unless [String, Regexp].include? path.class
			@path = path
			@method = method
			@action = action
			@match_data = nil
		end

		# Returns true if the combination of method and path matches this route.
		def matches?(method, path)
			case @path
			when String
				@method == method && @path == path
			when Regexp
				@match_data = @path.match path
				@method == method && @match_data
			end
		end

		# Execute this route's actions.
		def execute
			status = 200
			headers = { 'Content-Type' => 'text/html; charset=utf-8' }
			body = @action.call
			{ status: status, headers: headers, body: body }
		end
	end
end
