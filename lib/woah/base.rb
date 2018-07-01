# frozen_string_literal: true

module Woah
	# Base for apps
	class Base
		@@before = nil
		@@after = nil
		@@match_data = nil
		@@request = nil
		@@routes = []

		def initialize
			@@override = {}
			@@match_data = nil
			@@response = nil
		end

		# Answer the phone.
		# Finds a relevant route for the parameters in env,
		# and builds a response.
		def call(env)
			initialize

			@@request = Rack::Request.new env

			@@before&.call

			@@response = resolve_route env['REQUEST_METHOD'], env['REQUEST_URI']

			@@after&.call

			%i[status headers body].each do |r|
				@@response[r] = @@override[r] unless @@override[r].nil?
			end

			@@response.values
		end

		# Resolves and executes a round
		def resolve_route(method, path)
			route = @@routes.select { |r| r.matches?(method, path) }[0]

			if route.nil?
				return {
					status: 404,
					headers: { 'Content-Type' => 'text/html; charset=utf-8' },
					body: 'not found L:'
				}
			end

			@@match_data = route.match_data if route.match_data

			route.execute
		end

		class << self
			def call(env)
				new.call env
			end

			# Get this show on the road.
			def run!(host = '0.0.0.0', port = 4422)
				Rack::Handler.pick(%w[thin webrick]).run new, Host: host, Port: port
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

			# Redirect to another route.
			def redirect_to(path, method = 'GET')
				result = new.resolve_route method, path

				%i[status headers].each do |r|
					set r, result[r]
				end

				result[:body]
			end

			# Override an item in the response.
			def set(item, content)
				raise "unknown item #{item}, cannot override" unless %i[status headers body].include? item

				@@override[item] = content
			end

			# Set or read cookies
			def cookie(key, value = nil)
				if value.nil?
					# Read cookie
					@@request.env['HTTP_COOKIE']&.split('; ')&.each do |c|
						s = c.split('=')
						return s[1] if s[0] == key
					end
					nil # if not found
				else
					# Set cookie
					@@override[:headers] = {}
					Rack::Utils.set_cookie_header!(@@override[:headers], key, value)
				end
			end

			# Get match data from Regexp routes.
			def match
				@@match_data
			end

			# Get request object
			def request
				@@request
			end
		end
	end
end
