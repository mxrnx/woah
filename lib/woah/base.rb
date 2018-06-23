# frozen_string_literal: true

module Woah
	# Base for apps
	class Base
		@@before = nil
		@@after = nil
		@@routes = []

		# Answer the phone.
		# Finds a relevant route for the parameters in env,
		# and builds a response.
		def self.call(env)
			route = @@routes.select { |r| r.matches?(env['REQUEST_METHOD'], env['REQUEST_URI']) }[0]
			@@override = {}

			@@before&.call

			return [404, { 'Content-Type' => 'text/html; charset=utf-8' }, 'not found L:'] if route.nil?

			response = route.execute
			%i[status headers body].each do |r|
				response[r] = @@override[r] unless @@override[r].nil?
			end
			@@after&.call

			response.values
		end

		# Register new routes. The optional method argument can be used to specify a method.
		def self.on(path, method = 'GET', &action)
			raise 'unknown method' unless %w[DELETE GET HEAD OPTIONS PATCH POST PUT].include? method

			@@routes.push Route.new(path, method, &action)
		end

		# Action that will be called before every route.
		def self.before(&action)
			@@before = action
		end

		# Action that will be called after every route.
		def self.after(&action)
			@@after = action
		end

		# Override an item in the response.
		def self.set(item, content)
			unless %i[status headers body].include? item
				raise 'unknown item ' + item.to_s + ', cannot override'
			end

			@@override[item] = content
		end

		# Get this show on the road.
		def self.run!(port = 4422)
			Rack::Handler.pick(%w[thin webrick]).run new, Port: port
		end
	end
end
