# frozen_string_literal: true

module Woah
	# Base for apps
	class Base
		@@before = nil
		@@after = nil
		@@routes = {}

		# answer the phone
		def self.call(env)
			route = @@routes[[env['REQUEST_URI'], env['REQUEST_METHOD']]]
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

		# register new routes
		def self.on(path, method = 'GET', &action)
			raise 'unknown method' unless %w[DELETE GET HEAD OPTIONS PATCH POST PUT].include? method
			@@routes[[path, method]] = Route.new(path, method, &action)
		end

		# things to do before handling the routes
		def self.before(&action)
			@@before = action
		end

		# things to do after handling the routes
		def self.after(&action)
			@@after = action
		end

		# override an item in the response
		def self.set(item, content)
			unless %i[status headers body].include? item
				raise 'unknown item ' + item.to_s + ', cannot override'
			end
			@@override[item] = content
		end

		# get this show on the road
		def self.run!(port = 4422)
			Rack::Handler.pick(%w[thin webrick]).run new, Port: port
		end
	end
end
