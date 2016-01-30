require 'test_helper'

class MotionVj::Helpers::InputTest < Minitest::Test
  def test_gets_valid_input
    $stdin = StringIO.new('foo')
    assert_output do
      assert_equal 'foo', MotionVj::Helpers::Input.gets_until_not_blank
    end
  end

  def test_prints_validation_with_default_input_name_and_gets_next_input
    $stdin = StringIO.new("\nbar")
    assert_output 'Please provide a valid input: ' do
      assert_equal 'bar', MotionVj::Helpers::Input.gets_until_not_blank
    end
  end

  def test_prints_validation_with_provided_input_name_and_gets_next_input
    $stdin = StringIO.new("\nfoo")
    assert_output 'Please provide a valid code: ' do
      assert_equal 'foo', MotionVj::Helpers::Input.gets_until_not_blank(:code)
    end
  end
end
