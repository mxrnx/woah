# frozen_string_literal: true

class BeforeAfterTest < MiniTest::Test
  def setup
    @env = {}
  end

  def test_get_before
    @env['REQUEST_URI'] = '/before'
    @env['REQUEST_METHOD'] = 'GET'

    response = TestApp.call @env

    assert_equal 200, response[0]
    assert_equal 'chunky', response[2][0]

    @env['REQUEST_URI'] = '/after'

    response = TestApp.call @env

    assert_equal 200, response[0]
    assert_equal 'bacon', response[2][0]
  end
end
