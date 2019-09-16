# frozen_string_literal: true

module Woah
	# Base for apps.
	class Base
		@@before = nil
		@@after = nil
		@@routes = []

		def initialize
			@@override = {}
			@@match = nil
			@@request = nil
			@@response = nil
		end

		# Answer the phone.
		# Finds a relevant route for the parameters in env,
		# and builds a response.
		def call(env)
			initialize

			@@request = Rack::Request.new env

			@@before&.call

			@@response = resolve_route env['REQUEST_URI'], env['REQUEST_METHOD']

			@@after&.call

			override_values

			# make sure we do not give nil bodies to the server
			@@response[:body] ||= ''
			@@response[:body] = [@@response[:body]]

			@@response.values
		end

		# Applies user overrides.
		def override_values
			%i[status headers body].each do |r|
				@@response[r] = @@override[r] unless @@override[r].nil?
			end
		end

		# Resolves and executes a round.
		# @param path [String, Regexp] the path to respond to
		# @param method [String] the HTTP method to use
		# @return [Hash] the route's response
		def resolve_route(path, method)
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
			# Forwards to a new instance's #call method.
			def call(env)
				new.call env
			end

			# Get this show on the road.
			# @param host [String] the host to use
			# @param port [Integer] the port to use
			def run!(host = '0.0.0.0', port = 4422)
				Rack::Handler.pick(%w[thin puma]).run new, Host: host, Port: port
			end

			# Register new routes. The optional method argument can be used to specify
			# a method.
			# @param path [String, Regexp] the path to respond to
			# @param method [String] the HTTP method to use
			# @raise [ArgumentError] if `method` is not a valid HTTP method
			def on(path, method = 'GET', &action)
				unless %w[DELETE GET HEAD OPTIONS PATCH POST PUT].include? method
					raise ArgumentError, 'Unknown method'
				end

				@@routes.push Route.new(path, method, &action)
			end

			# Takes a block that will be executed before every route.
			def before(&action)
				@@before = action
			end

			# Takes a block that will be executed after every route.
			def after(&action)
				@@after = action
			end

			# Redirect to another route.
			# @param path [String, Regexp] the path to redirect to
			# @param method [String] the HTTP method to use
			# @return [String] the redirect's body
			def redirect_to(path, method = 'GET')
				result = new.resolve_route path, method

				%i[status headers].each do |r|
					set r, result[r]
				end

				result[:body]
			end

			# Override an item in the response.
			# @param item [:status, :headers, :body] the item to be overriden
			# @param content the content to override the item with
			# @raise [ArgumentError] if item is outside the range of accepted values
			def set(item, content)
				unless %i[status headers body].include? item
					raise ArgumentError, "Unknown item #{item}, cannot override"
				end

				@@override[item] = content
			end

			# Set or read cookies.
			# Depending on the type of `value`, respectively reads, deletes, or sets
			# a cookie.
			# @param key [String] the name of the cookie
			# @param value [nil, :delete, String]
			def cookie(key, value = nil)
				if value.nil?
					read_cookie key
				elsif value == :delete
					del_cookie key
				elsif value.is_a? String
					set_cookie key, value
				else
					raise ArgumentError, 'Value should be either nil, :delete, or a string'
				end
			end

			# Returns the value of class attribute match.
			def match
				@@match
			end

			# Returns the value of class attribute request.
			def request
				@@request
			end

			private

			def read_cookie(key)
				@@request.env['HTTP_COOKIE']&.split('; ')&.each do |c|
					s = c.split('=')
					return s[1] if s[0] == key
				end
				nil # if not found
			end

			def del_cookie(key)
				@@override[:headers] ||= {}
				Rack::Utils.delete_cookie_header! @@override[:headers], key
			end

			def set_cookie(key, value)
				@@override[:headers] ||= {}
				Rack::Utils.set_cookie_header! @@override[:headers], key, value
			end
		end
	end
end
