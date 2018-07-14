RSpec.describe ObjectProtocol do
  describe "#satisfied_by?" do
    context 'a simple logging protocol' do
      let(:device) { [] }

      let(:protocol) do
        Protocols::Logging.new.bind(
          device: device,
          logger: Protocols::Logging::Logger.new(device),
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
end
