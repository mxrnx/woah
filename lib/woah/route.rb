# frozen_string_literal: true

module Woah
	# Holds Woah! routes
	class Route
		def initialize(path, method, &action)
			@path = path
			@method = method
			@action = action
		end

		def execute
			status = 200
			headers = { 'Content-Type' => 'text/html; charset=utf-8' }
			body = @action.call
			{ status: status, headers: headers, body: body }
		end
	end
end
