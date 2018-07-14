require 'object_protocol'

module Protocols
  module Logging
    def self.new
      ObjectProtocol.new(:logger, :device) do
        logger.sends(:<<).to(device).with("message")
      end
    end

    class Logger
      def initialize(device)
        @device = device
      end
      def info(message)
        @device << message
      end
      def rotate
        @device.shift
      end      
    end
  end
end
