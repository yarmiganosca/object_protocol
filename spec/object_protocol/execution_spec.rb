require 'object_protocol/execution'

class ObjectProtocol
  RSpec.describe Execution do
    it 'tracks messages' do
      device = []
      logger = Protocols::Logging::Logger.new(device)

      execution = Execution.new(logger, device) { logger.info("message") }
      protocol  = Protocols::Logging.new.bind(device: device, logger: logger)

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
