class BeforeAfterTest < MiniTest::Test
	def setup
		@env = {}
	end

	def test_get_before
		@env['REQUEST_URI'] = '/before_after'
		@env['REQUEST_METHOD'] = 'GET'

		response = TestApp.call @env

		assert_equal 200, response[0]
		assert_equal 'chunky', response[2]

		response = TestApp.call @env

		assert_equal 200, response[0]
		assert_equal 'bacon', TestApp.get_time
	end
end
