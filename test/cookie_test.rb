# frozen_string_literal: true

class CookieTest < MiniTest::Test
	def setup
		@env = {}
	end

	def test_get_cookie
		@env['REQUEST_URI'] = '/get_cookie'
		@env['REQUEST_METHOD'] = 'GET'
		@env['HTTP_COOKIE'] = 'test=something'
		response = TestApp.call @env

		assert_equal 200, response[0]
		assert_equal 'something', response[2]
	end

	def test_get_nonexistent_cookie
		@env['REQUEST_URI'] = '/get_cookie'
		@env['REQUEST_METHOD'] = 'GET'
		response = TestApp.call @env

		assert_equal 200, response[0]
		assert_equal nil, response[2]
	end

	def test_set_cookie
		@env['REQUEST_URI'] = '/set_cookie'
		@env['REQUEST_METHOD'] = 'GET'
		response = TestApp.call @env

		assert_equal 200, response[0]
		assert_equal 'fruit=apple', response[1]['Set-Cookie']
		assert_equal nil, response[2]
	end
end
