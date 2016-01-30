require 'dropbox_sdk'

module MotionVj
  class Client
    attr_reader :db_client, :videos_dir

    def initialize(token, videos_dir)
      @db_client = DropboxClient.new(token)
      @videos_dir = videos_dir
    end

    def file_exist?(filename)
      begin
        metadata = self.db_client.metadata(File.join(self.videos_dir, filename))
        metadata && !metadata['is_dir'] && metadata['bytes'] && metadata['bytes'] > 0
      rescue DropboxError => e
        false
      end
    end

    def upload(filepath)
      open(filepath) do |file|
        metadata = self.db_client.put_file(File.join(self.videos_dir, File.basename(filepath)), file, true)
        metadata && !metadata['is_dir'] && metadata['bytes'] && metadata['bytes'] > 0
      end
    end

    def self.get_token(app_key, app_secret)
      flow = DropboxOAuth2FlowNoRedirect.new(app_key, app_secret)
      authorize_url = flow.start

      puts "1. Go to: #{ authorize_url }"
      puts '2. Click "Allow" (you might have to log in first)'
      puts '3. Copy the authorization code'
      print 'Enter the authorization code here: '
      code = MotionVj::Helpers::Input.gets_until_not_blank(:code)

      flow.finish(code).first
    end
  end
end
