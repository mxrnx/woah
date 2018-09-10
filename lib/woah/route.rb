# frozen_string_literal: true

module Woah
	# A Woah! routes
	class Route
		attr_accessor :match

		def initialize(path, method, &action)
			raise 'only strings and regexps are valid paths' unless [String, Regexp].include? path.class

			@path = path
			@method = method
			@action = action
			@match = nil
		end

		# Checks if a given route is the same as this one
		# @param path [String, Regexp] the path to redirect to
		# @param method [String] the HTTP method to use
		# @return [Boolean] true if given method and path match this route
		def matches?(method, path)
			case @path
			when String
				@method == method && @path == path
			when Regexp
				@match = @path.match path
				@method == method && @match
			end
		end

		# Execute this route's actions.
		# @return [Hash] the route's response
		def execute
			status = 200
			headers = { 'Content-Type' => 'text/html; charset=utf-8' }
			body = @action.call
			{ status: status, headers: headers, body: body }
		end
	end
end
