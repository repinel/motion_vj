require 'motion_vj/client'
require 'motion_vj/logger'
require 'motion_vj/version'
require 'motion_vj/helpers'

require 'fileutils'
require 'listen'

module MotionVj
  def self.get_dropbox_token(app_key, app_secret)
    token = MotionVj::Client.get_token(app_key, app_secret)
    puts "Your Dropbox access token for this app is: #{ token }"
  end

  def self.start(options)
    listener = Listen.to(options[:videos_dir], only: /\.#{ Regexp.escape options[:videos_extension] }$/) do |modified_filepaths, _, removed_filepaths|
      # handle addded files
      unless modified_filepaths.empty?
        client = MotionVj::Client.new(options[:db_app_token], options[:db_videos_dir])
        motion_lsof = `lsof -c #{ options[:motion_cmd] }`

        modified_filepaths.each do |filepath|
          file_basename = File.basename filepath

          if motion_lsof =~ /#{ Regexp.escape(file_basename) }/
            Logger.error "Added file still in use."
            next
          end

          # if not being updated && not already uploaded
          if !client.file_exist?(file_basename)
            begin
              if client.upload(filepath)
                FileUtils.rm_f(filepath)
                Logger.info "'#{ file_basename }' was uploaded."
              else
                Logger.error "Could not upload '#{ file_basename }'."
              end
            rescue => e
              Logger.error "Could not upload '#{ file_basename }'."
            end
          end
        end
      end

      # handle removed files
      removed_filepaths.each do |filepath|
        Logger.info "'#{ File.basename(filepath) }' deleted."
      end
    end
    listener.start
  end
end
