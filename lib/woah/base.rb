# frozen_string_literal: true

module Woah
	# Base for apps
	class Base
		@@before = nil
		@@after = nil
		@@match = nil
		@@request = nil
		@@routes = []

		def initialize
			@@override = {}
			@@match = nil
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

			override_values

			# make sure we do not give nil bodies to the server
			@@response[:body] ||= ''
			@@response[:body] = [@@response[:body]]

			@@response.values
		end

		# Applies user overrides
		def override_values
			%i[status headers body].each do |r|
				@@response[r] = @@override[r] unless @@override[r].nil?
			end
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

			@@match = route.match if route.match

			route.execute
		end

		class << self
			def call(env)
				new.call env
			end

			# Get this show on the road.
			def run!(host = '0.0.0.0', port = 4422)
				Rack::Handler.pick(%w[thin puma]).run new, Host: host, Port: port
			end

			# Register new routes. The optional method argument can be used to specify a method.
			def on(path, method = 'GET', &action)
				unless %w[DELETE GET HEAD OPTIONS PATCH POST PUT].include? method
					raise ArgumentError, 'Unknown method'
				end

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
				unless %i[status headers body].include? item
					raise ArgumentError, "Unknown item #{item}, cannot override"
				end

				@@override[item] = content
			end

			# Set or read cookies
			# Value should be either: nil, to read a cookie; a string, to set a cookie; or :delete, to
			# delete a cookie
			def cookie(key, value = nil)
				# Read cookie
				if value.nil?
					@@request.env['HTTP_COOKIE']&.split('; ')&.each do |c|
						s = c.split('=')
						return s[1] if s[0] == key
					end
					nil # if not found

				# Delete cookie
				elsif value == :delete
					@@override[:headers] = {}
					Rack::Utils.delete_cookie_header! @@override[:headers], key

				# Set cookie
				elsif value.is_a? String
					@@override[:headers] = {}
					Rack::Utils.set_cookie_header! @@override[:headers], key, value

				# Invalid argument
				else
					raise ArgumentError, 'Value should be either nil, :delete, or a string'
				end
			end

			# Get match data from Regexp routes.
			def match
				@@match
			end

			# Get request object
			def request
				@@request
			end
		end
	end
end
