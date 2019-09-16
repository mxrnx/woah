# frozen_string_literal: true

class MiscTest < MiniTest::Test
  def test_bad_route_init
    assert_raises ArgumentError do
      Woah::Route.new(123, 'POST') do
        puts 'this will never happen'
      end
    end
  end

  # smoke test, will fail on exceptions
  def test_smoke
    thread = Thread.new do
      TestApp.run! 'localhost'
    end

    sleep 2

    thread.kill
  end
end
