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

    describe 'spying on #method_missing invocations' do
      class MethodMissingSender
        def initialize(receiver)
          @receiver = receiver
        end

        def send_message(message, *args)
          eval("@receiver.#{message}(*args)") # so we don't record a #send call
        end
      end

      class MethodMissingReceiver
        def method_missing(name, *args, &blk)
          name == :good ? return : super
        end
      end

      let(:protocol) { ObjectProtocol.new(:sender, :receiver) { } }
      let(:receiver) { MethodMissingReceiver.new }
      let(:sender)   { MethodMissingSender.new(receiver) }

      before { protocol.bind(sender: sender, receiver: receiver) }

      context 'when the message is valid' do
        subject(:execution) do
          Execution.new(sender, receiver) do
            sender.send_message(:good, :z, 4)
          end
        end

        it 'records the message being sent' do
          execution.call(protocol)

          expect(execution.messages).to eq [
            SentMessage.new(
              sender:   sender,
              receiver: receiver,
              name:     :good
            ).with([:z, 4])
          ]
        end
      end

      context 'when the message is invalid' do
        subject(:execution) do
          Execution.new(sender, receiver) do
            sender.send_message(:bad)
          end
        end

        it 'results in a NoMethodError as is normal' do
          expect { execution.call(protocol) }.to raise_error NoMethodError
        end
      end
    end
  end
end
