class BasicVerbsTest < MiniTest::Test
	def setup
		@env = {}
	end

	def test_get_root
		@env['REQUEST_URI'] = '/'
		@env['REQUEST_METHOD'] = 'GET'
		response = TestApp.call @env

		assert_equal 200, response[0]
		assert_equal 'hi there!', response[2]
	end

	def test_get_404
		@env['REQUEST_URI'] = '/does/not/exist'
		@env['REQUEST_METHOD'] = 'GET'
		response = TestApp.call @env

		assert_equal 404, response[0]
	end
end
