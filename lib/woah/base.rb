# frozen_string_literal: true

module Woah
	# Base for apps
	class Base
		@@before = nil
		@@after = nil
		@@match_data = nil
		@@routes = []

		class << self
			# Get this show on the road.
			def run!(port = 4422)
				Rack::Handler.pick(%w[thin webrick]).run new, Port: port
			end

			# Answer the phone.
			# Finds a relevant route for the parameters in env,
			# and builds a response.
			def call(env)
				@@override = {}
				@@match_data = nil

				@@before&.call

				response = handle_route env

				@@after&.call

				response
			end

			# Register new routes. The optional method argument can be used to specify a method.
			def on(path, method = 'GET', &action)
				raise 'unknown method' unless %w[DELETE GET HEAD OPTIONS PATCH POST PUT].include? method

				@@routes.push Route.new(path, method, &action)
			end

			# Action that will be called before every route.
			def before(&action)
				@@before = action
			end

			# Action that will be called after every route.
			def after(&action)
				@@after = action
			end

			# Override an item in the response.
			def set(item, content)
				unless %i[status headers body].include? item
					raise 'unknown item ' + item.to_s + ', cannot override'
				end

				@@override[item] = content
			end

			# Get match data from Regexp routes.
			def match
				@@match_data
			end

			private

			def handle_route(env)
				route = @@routes.select { |r| r.matches?(env['REQUEST_METHOD'], env['REQUEST_URI']) }[0]

				return [404, { 'Content-Type' => 'text/html; charset=utf-8' }, 'not found L:'] if route.nil?

				@@match_data = route.match_data if route.match_data

				response = route.execute
				%i[status headers body].each do |r|
					response[r] = @@override[r] unless @@override[r].nil?
				end

				response.values
			end
		end
	end
end
