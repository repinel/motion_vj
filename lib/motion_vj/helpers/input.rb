module MotionVj
  module Helpers
    module Input
      def self.gets_until_not_blank(input_name = :input)
        loop do
          value = $stdin.gets.to_s.strip
          if value.empty?
            print("Please provide a valid #{input_name}:")
          else
            return value  
          end
        end
      end
    end
  end
end
