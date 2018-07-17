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

  describe "#in_any_order" do
    let(:endpointA) { Protocols::ParallelRequests::Endpoint.new }
    let(:endpointB) { Protocols::ParallelRequests::Endpoint.new }
    let(:protocol) do
      Protocols::ParallelRequests.new.bind(
        client:    client,
        endpointA: endpointA,
        endpointB: endpointB,
      )
    end

    context "endpoint A being queried before endpoint B" do
      let(:client) { Protocols::ParallelRequests::Client.new([endpointA, endpointB]) }

      it 'satisfies the parallel request protocol' do
        expect(protocol.satisfied_by? { client.request }).to be true
      end
    end

    context "endpoint B being queried before endpoint A" do
      let(:client) { Protocols::ParallelRequests::Client.new([endpointB, endpointA]) }

      it 'satisfies the parallel request protocol' do
        expect(protocol.satisfied_by? { client.request }).to be true
      end
    end
  end

  describe "#to_rspec_matcher_failure_message_lines" do
    context "with a protocol with an unordered sequence" do
      let(:protocol) { Protocols::ParallelRequests.new }

      it 'groups the indented expectations under in_any_order' do
        expect(protocol.to_rspec_matcher_failure_message_lines).to eq [
          "in_any_order",
          "  client.sends(:get).to(endpointA)",
          "  client.sends(:get).to(endpointB)",
        ]
      end
    end
  end
end
