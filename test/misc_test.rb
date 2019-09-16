# frozen_string_literal: true

class MiscTest < MiniTest::Test
  def test_bad_route_init
    assert_raises ArgumentError do
      Woah::Route.new(123, 'POST') do
        puts 'this will never happen'
      end
    end
  end
end
