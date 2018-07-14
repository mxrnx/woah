# frozen_string_literal: true

class OnMethodTest < MiniTest::Test
	def setup
		@env = {}
	end

	def test_throw_404
		TestApp.on '/404' do
			TestApp.set :status, 404
			"it's a secret to everybody"
		end

		@env['REQUEST_URI'] = '/404'
		@env['REQUEST_METHOD'] = 'GET'
		response = TestApp.call @env

		assert_equal 404, response[0]
		assert_equal "it's a secret to everybody", response[2][0]
	end

	def test_regexp_path
		TestApp.on %r{^/regex/[0-9]+$} do
			'heya'
		end

		@env['REQUEST_URI'] = '/regex/22'
		@env['REQUEST_METHOD'] = 'GET'
		response = TestApp.call @env

		assert_equal 200, response[0]

		@env['REQUEST_URI'] = '/regex/seventy'
		response = TestApp.call @env

		assert_equal 404, response[0]
	end

	def test_regexp_match_data
		TestApp.on %r{^/myname/(\w+)$} do
			'hi there, ' + TestApp.match[1]
		end

		@env['REQUEST_URI'] = '/myname/Charles'
		@env['REQUEST_METHOD'] = 'GET'
		response = TestApp.call @env

		assert_equal 200, response[0]
		assert_equal 'hi there, Charles', response[2][0]
	end

	def test_illegal_method
		assert_raises ArgumentError do
			TestApp.on '/', 'BUBBLES' do
				'oOooo oO oO'
			end
		end

		@env['REQUEST_URI'] = '/'
		@env['REQUEST_METHOD'] = 'BUBBLES'
		response = TestApp.call @env

		assert_equal 404, response[0]
	end

	def test_illegal_set
		@env['REQUEST_URI'] = '/nose'
		@env['REQUEST_METHOD'] = 'GET'

		assert_raises ArgumentError do
			TestApp.call @env
		end
	end

	def test_request_object
		@env['REQUEST_URI'] = '/ip'
		@env['REQUEST_METHOD'] = 'GET'
		response = TestApp.call @env

		assert_equal 200, response[0]
		assert_equal '/ip', response[2][0]
	end
end
