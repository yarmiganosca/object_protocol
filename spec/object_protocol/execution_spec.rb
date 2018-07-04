require 'object_protocol/execution'

class ObjectProtocol
  RSpec.describe Execution do
    it 'tracks messages' do
      class Logger
        def initialize(device)
          @device = device
        end
        def info(message)
          @device << message
        end
      end

      device = []
      logger = Logger.new(device)

      execution = Execution.new(logger, device) { logger.info("message") }
      protocol  = ObjectProtocol.new {}.bind(device: device, logger: logger)

      execution.call(protocol)

      expect(execution.messages).to eq [
        SentMessage.new(
          sender:    logger,
          receiver:  device,
          name:      :<<,
        ).with(["message"]),
      ]
    end
  end
end
