# frozen_string_literal: true

class RedirectTest < MiniTest::Test
	def setup
		@env = {}
	end

	# rubocop:disable Style/GlobalVars
	def test_redirect
		TestApp.on '/goback' do
			$something = 'gone back'
			TestApp.redirect_to '/'
		end

		@env['REQUEST_URI'] = '/goback'
		@env['REQUEST_METHOD'] = 'GET'
		response = TestApp.call @env

		assert_equal 200, response[0]
		assert_equal 'hi there!', response[2][0]
		assert_equal 'gone back', $something
	end
		# rubocop:enable Style/GlobalVars
end
