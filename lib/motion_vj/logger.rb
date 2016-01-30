module MotionVj
  module Logger
    def self.info(msg)
      $stdout.puts format(msg, 'INFO')
    end

    def self.error(msg)
      $stderr.puts format(msg, 'ERROR')
    end

    private

    def self.format(msg, type)
      "[motionvj][#{ Time.now.utc.strftime("%Y-%m-%d %H:%M:%S %Z") }][#{ type }]: #{ msg }"
    end
  end
end
