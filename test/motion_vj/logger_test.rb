require 'test_helper'

class MotionVj::LoggerTest < Minitest::Test
  def test_logs_info
    assert_output "[motionvj][2015-12-07 18:30:45 UTC][INFO]: foo bar\n" do
      Time.stub :now, DateTime.new(2015, 12, 7, 21, 30, 45, '+3').to_time do
        MotionVj::Logger.info 'foo bar'
      end
    end
  end

  def test_logs_error
    assert_output nil, "[motionvj][2015-12-06 20:25:30 UTC][ERROR]: goo bar\n" do
      Time.stub :now, DateTime.new(2015, 12, 7, 3, 25, 30, '+7').to_time do
        MotionVj::Logger.error 'goo bar'
      end
    end
  end
end
