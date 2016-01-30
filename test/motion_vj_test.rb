require 'test_helper'

class MotionVjTest < Minitest::Test
  def setup
    @fake_token = 'fake1234'
    @fake_db_videos_dir = 'my_app_videos'
  end

  def test_gem_version_number
    refute_nil ::MotionVj::VERSION
  end

  def test_gets_dropbox_token
    mock = MiniTest::Mock.new.expect(:call, @fake_token, ['foo', 'bar'])
    assert_output "Your Dropbox access token for this app is: #{ @fake_token }\n" do
      MotionVj::Client.stub :get_token, mock do
        MotionVj.get_dropbox_token('foo', 'bar')
      end
    end
    mock.verify
  end

  def test_uploads_modified_files
    create_tmpdir do |tmpdir, tmpfile|
      file_basename = File.basename tmpfile

      client_mock = MiniTest::Mock.new
      client_mock.expect(:file_exist?, false, [file_basename])
      client_mock.expect(:upload, true, [tmpfile])
      new_client_mock = MiniTest::Mock.new.expect(:call, client_mock, [@fake_token, @fake_db_videos_dir])

      assert_output /'#{ Regexp.escape(file_basename) }' was uploaded\./, '' do
        MotionVj::Client.stub :new, new_client_mock do
          MotionVj.start(db_app_token:     @fake_token,
                         db_videos_dir:    @fake_db_videos_dir,
                         motion_cmd:       'motion',
                         videos_dir:       tmpdir,
                         videos_extension: extension(tmpfile))
          wait
          FileUtils.touch(tmpfile)
          wait
        end
      end

      refute File.exist?(tmpfile), 'file must be deleted after uploaded'

      client_mock.verify
      new_client_mock.verify
    end
  end

  def test_does_not_delete_file_when_upload_fails
    create_tmpdir do |tmpdir, tmpfile|
      file_basename = File.basename tmpfile

      client_mock = MiniTest::Mock.new
      client_mock.expect(:file_exist?, false, [file_basename])
      client_mock.expect(:upload, false, [tmpfile])
      new_client_mock = MiniTest::Mock.new.expect(:call, client_mock, [@fake_token, @fake_db_videos_dir])

      assert_output '', /Could not upload '#{ Regexp.escape (file_basename) }'\./ do
        MotionVj::Client.stub :new, new_client_mock do
          MotionVj.start(db_app_token:     @fake_token,
                         db_videos_dir:    @fake_db_videos_dir,
                         motion_cmd:       'motion',
                         videos_dir:       tmpdir,
                         videos_extension: extension(tmpfile))
          wait
          FileUtils.touch(tmpfile)
          wait
        end
      end

      assert File.exist?(tmpfile), 'file must not be deleted when not uploaded'

      client_mock.verify
      new_client_mock.verify
    end
  end

  def test_does_not_delete_file_when_upload_fails_with_exception
    create_tmpdir do |tmpdir, tmpfile|
      file_basename = File.basename tmpfile

      client_mock = MiniTest::Mock.new
      client_mock.expect(:file_exist?, false, [file_basename])
      client_mock.expect(:upload, nil) do
        raise 'upload failed'
      end
      new_client_mock = MiniTest::Mock.new.expect(:call, client_mock, [@fake_token, @fake_db_videos_dir])

      assert_output '', /Could not upload '#{ Regexp.escape(file_basename) }'\./ do
        MotionVj::Client.stub :new, new_client_mock do
          MotionVj.start(db_app_token:     @fake_token,
                         db_videos_dir:    @fake_db_videos_dir,
                         motion_cmd:       'motion',
                         videos_dir:       tmpdir,
                         videos_extension: extension(tmpfile))
          wait
          FileUtils.touch(tmpfile)
          wait
        end
      end

      assert File.exist?(tmpfile), 'file must not be deleted when not uploaded'

      client_mock.verify
      new_client_mock.verify
    end
  end

  def test_does_not_upload_modified_files_already_uploaded
    create_tmpdir do |tmpdir, tmpfile|
      file_basename = File.basename tmpfile

      client_mock = MiniTest::Mock.new
      client_mock.expect(:file_exist?, true, [file_basename])
      new_client_mock = MiniTest::Mock.new.expect(:call, client_mock, [@fake_token, @fake_db_videos_dir])

      assert_output '', '' do
        MotionVj::Client.stub :new, new_client_mock do
          MotionVj.start(db_app_token:     @fake_token,
                         db_videos_dir:    @fake_db_videos_dir,
                         motion_cmd:       'motion',
                         videos_dir:       tmpdir,
                         videos_extension: extension(tmpfile))
          wait
          FileUtils.touch(tmpfile)
          wait
        end
      end

      assert File.exist?(tmpfile), 'file must not be deleted when not uploaded'

      client_mock.verify
      new_client_mock.verify
    end
  end

  def test_ignores_some_modified_files
    create_tmpdir do |tmpdir, tmpfile|
      file_basename = File.basename tmpfile

      client_mock = MiniTest::Mock.new
      new_client_mock = MiniTest::Mock.new

      assert_output '', '' do
        MotionVj::Client.stub :new, new_client_mock do
          MotionVj.start(db_app_token:     @fake_token,
                         db_videos_dir:    @fake_db_videos_dir,
                         motion_cmd:       'motion',
                         videos_dir:       tmpdir,
                         videos_extension: 'avi')
          wait
          FileUtils.touch(tmpfile)
          wait
        end
      end

      assert File.exist?(tmpfile), 'file must not be deleted when not uploaded'

      client_mock.verify
      new_client_mock.verify
    end
  end

  def test_logs_when_file_deleted
    create_tmpdir do |tmpdir, tmpfile|
      assert_output /'#{ Regexp.escape(File.basename(tmpfile)) }' deleted\./, '' do
        MotionVj.start(db_app_token:     @fake_token,
                       db_videos_dir:    @fake_db_videos_dir,
                       motion_cmd:       'motion',
                       videos_dir:       tmpdir,
                       videos_extension: extension(tmpfile))
        wait
        FileUtils.rm_f(tmpfile)
        wait
      end
    end
  end

  def test_ignores_some_deleted_files
    create_tmpdir do |tmpdir, tmpfile|
      assert_output '', '' do
        MotionVj.start(db_app_token:     @fake_token,
                       db_videos_dir:    @fake_db_videos_dir,
                       motion_cmd:       'motion',
                       videos_dir:       tmpdir,
                       videos_extension: 'avi')
        wait
        FileUtils.rm_f(tmpfile)
        wait
      end
    end
  end

  private

  def create_tmpdir
    tmpdir = Dir.mktmpdir(nil, File.dirname(__FILE__))
    tmpfile = "#{ tmpdir }/foo.bar"
    FileUtils.touch(tmpfile)
    yield tmpdir, tmpfile
  ensure
    Listen.stop
    FileUtils.rm_rf(tmpdir) if tmpdir
  end

  def wait
    sleep 1
  end

  def extension(filename)
    File.extname(filename).sub('.', '')
  end
end
