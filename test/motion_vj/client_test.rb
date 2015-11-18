require 'test_helper'

class MotionVj::ClientTest < Minitest::Test
  def test_file_exists_when_not_a_directory_and_not_empty
    mock_db_client
    @db_client_mock.expect(:metadata, {'is_dir' => false, 'bytes' => 1}, ['my_app_videos/foo.bar'])
    @db_client_mock.expect(:metadata, {'is_dir' => false, 'bytes' => 0}, ['my_app_videos/foo.bar'])
    @db_client_mock.expect(:metadata, {'is_dir' => true, 'bytes' => 1}, ['my_app_videos/foo.bar'])
    @db_client_mock.expect(:metadata, nil, ['my_app_videos/foo.bar'])
    @db_client_mock.expect(:metadata, nil) { raise DropboxError.new('foo') }

    DropboxClient.stub :new, @new_db_client_mock do
      client = MotionVj::Client.new(@fake_token)
      assert client.file_exist?('foo.bar')
      refute client.file_exist?('foo.bar')
      refute client.file_exist?('foo.bar')
      refute client.file_exist?('foo.bar')
      refute client.file_exist?('foo.bar')
    end
  ensure
    verify_mock_db_client
  end

  def test_upload_is_successful_when_not_a_directory_and_not_empty
    tmpdir = Dir.mktmpdir(nil, File.dirname(__FILE__))
    tmpfile = "#{tmpdir}/foo.bar"
    FileUtils.touch(tmpfile)

    upload_ok = ->(filepath, file, overwrite) { 
      filepath == File.join('my_app_videos', 'foo.bar') && file.path == tmpfile && overwrite === true
    }
    mock_db_client
    @db_client_mock.expect(:put_file, {'is_dir' => false, 'bytes' => 1}, &upload_ok)
    @db_client_mock.expect(:put_file, {'is_dir' => false, 'bytes' => 0}, &upload_ok)
    @db_client_mock.expect(:put_file, {'is_dir' => true, 'bytes' => 1}, &upload_ok)
    @db_client_mock.expect(:put_file, nil, &upload_ok)
    @db_client_mock.expect(:put_file, nil) { raise DropboxError.new('foo') }

    DropboxClient.stub :new, @new_db_client_mock do
      client = MotionVj::Client.new(@fake_token)
      assert client.upload(tmpfile)
      refute client.upload(tmpfile)
      refute client.upload(tmpfile)
      refute client.upload(tmpfile)
      assert_raises DropboxError do
        client.upload(tmpfile)
      end
    end
  ensure
    FileUtils.rm_rf(tmpdir) if tmpdir
    verify_mock_db_client
  end

  def test_gets_the_token
    app_key = 'foo'
    app_secret = 'bar'
    db_oauth_mock = MiniTest::Mock.new
    new_db_oauth_mock = MiniTest::Mock.new.expect(:call, db_oauth_mock, [app_key, app_secret])

    db_oauth_mock.expect(:start, 'https://example.com/authorize')
    db_oauth_mock.expect(:finish, ['fake1234'], ['goo'])

    DropboxOAuth2FlowNoRedirect.stub :new, new_db_oauth_mock do
      $stdin = StringIO.new('goo')
      out = "1. Go to: https://example.com/authorize\n"\
            "2. Click \"Allow\" (you might have to log in first)\n"\
            "3. Copy the authorization code\n"\
            'Enter the authorization code here: '
      assert_output out, '' do
        assert_equal 'fake1234', MotionVj::Client.get_token(app_key, app_secret)
      end
    end
  ensure
    db_oauth_mock.verify
    new_db_oauth_mock.verify
  end

  private

  def mock_db_client
    ENV['DB_VIDEOS_DIR'] = 'my_app_videos'
    @fake_token = 'fake1234'
    @db_client_mock = MiniTest::Mock.new
    @new_db_client_mock = MiniTest::Mock.new.expect(:call, @db_client_mock, [@fake_token])
  end

  def verify_mock_db_client
    @db_client_mock.verify
    @new_db_client_mock.verify
  end
end
