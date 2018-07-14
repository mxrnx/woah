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
		assert_equal 'something', response[2][0]
	end

	def test_get_nonexistent_cookie
		@env['REQUEST_URI'] = '/get_cookie'
		@env['REQUEST_METHOD'] = 'GET'
		response = TestApp.call @env

		assert_equal 200, response[0]
		assert_equal '', response[2][0]
	end

	def test_set_cookie
		@env['REQUEST_URI'] = '/set_cookie'
		@env['REQUEST_METHOD'] = 'GET'
		response = TestApp.call @env

		assert_equal 200, response[0]
		assert_equal 'fruit=apple', response[1]['Set-Cookie']
		assert_equal '', response[2][0]
	end

	def test_set_illegal_cookie
		@env['REQUEST_URI'] = '/set_illegal_cookie'
		@env['REQUEST_METHOD'] = 'GET'

		assert_raises ArgumentError do
			TestApp.call @env
		end
	end

	def test_delete_cookie
		@env['REQUEST_URI'] = '/delete_cookie'
		@env['REQUEST_METHOD'] = 'GET'

		response = TestApp.call @env

		assert_equal 200, response[0]
		assert response[1]['Set-Cookie'].include? 'max-age=0'
	end
end
