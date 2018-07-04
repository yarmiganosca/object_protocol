RSpec.describe ObjectProtocol do
  describe 'a simple logging protocol' do
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
    let(:device) { [] }

    let(:protocol) do
      ObjectProtocol.new(:logger, :device) do
        logger.sends(:<<).to(device)#.with(/message/)
      end.bind(
        device: device,
        logger: Logger.new(device),
      )
    end

    it 'is satisfied by a correct execution' do
      expect(protocol.satisfied_by? { logger.info("message") }).to be true
    end

    it "isn't satisfied by an empty execution" do
      expect(protocol.satisfied_by? { }).to be false
    end

    it "isn't satisfied by an incorrect execution" do
      expect(protocol.satisfied_by? { logger.rotate }).to be false
    end
  end
end
