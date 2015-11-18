require 'motion_vj/client'
require 'motion_vj/logger'
require 'motion_vj/version'
require 'motion_vj/helpers'

require 'fileutils'
require 'listen'

module MotionVj
  def self.get_dropbox_token(app_key, app_secret)
    token = MotionVj::Client.get_token(app_key, app_secret)
    puts "Your Dropbox access token for this app is: #{token}"
  end

  def self.start(token)
    listener = Listen.to(ENV['VIDEOS_DIR'], only: /\.#{Regexp.escape ENV['VIDEO_EXTENTION']}$/) do |modified_filepaths, _, removed_filepaths|
      # handle addded files
      unless modified_filepaths.empty?
        client = MotionVj::Client.new(token)
        motion_lsof = `lsof -c #{ENV['MOTION_CMD']}`

        modified_filepaths.each do |filepath|
          file_basename = File.basename filepath

          if motion_lsof =~ /#{Regexp.escape file_basename}/
            Logger.error "Added file still in use."
            next
          end

          # if not being updated && not already uploaded
          if !client.file_exist?(file_basename)
            begin
              if client.upload(filepath)
                FileUtils.rm_f(filepath)
                Logger.info "'#{file_basename}' was uploaded."
              else
                Logger.error "Could not upload '#{file_basename}'."
              end
            rescue => e
              Logger.error "Could not upload '#{file_basename}'."
            end
          end
        end
      end

      # handle removed files
      removed_filepaths.each do |filepath|
        Logger.info "'#{File.basename(filepath)}' deleted."
      end
    end
    listener.start
  end
end
