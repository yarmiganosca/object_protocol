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

  describe '#bind' do
    let(:device)   { [] }
    let(:logger)   { Protocols::Logging::Logger.new(device) }
    let(:protocol) { Protocols::Logging.new }

    context 'not all collaborators are provided' do
      it 'raises an exception informing you logger was not provided' do
        expect { protocol.bind(device: device) }.to raise_error(/logger/)
      end
    end

    context 'undeclared collaborators are provided' do
      it 'raises an exception informing you x was provided' do
        expect { protocol.bind(device: device, logger: logger, x: 4) }.to raise_error(/x/)
      end
    end

    context 'not all collaborators are provided AND undeclared collaborators are provided' do
      let(:protocol_binding) { protocol.bind(device: device, x: 4) }

      it 'raises an exception informing you logger was not provided' do
        expect { protocol_binding }.to raise_error(/logger/)
      end

      it 'raises an exception informing you x was provided' do
        expect { protocol_binding }.to raise_error(/x/)
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

  describe "#in_order nested in an #in_any_order" do
    let(:protocol) do
      Protocols::CriticalSection.new.bind(
        lock:     lock,
        thread_a: thread_a,
        thread_b: thread_b,
      )
    end
    let(:lock)     { Protocols::CriticalSection::Lock.new }
    let(:thread_a) { Protocols::CriticalSection::Thread.new(lock: lock) }
    let(:thread_b) { Protocols::CriticalSection::Thread.new(lock: lock) }

    context "thread_a acquires; thread_a releases; thread_b acquires; thread_b releases" do
      it "satisfies the protocol" do
        expect(
          protocol.satisfied_by? do
            thread_a.acquire_lock
            thread_a.release_lock
            thread_b.acquire_lock
            thread_b.release_lock
          end
        ).to be true
      end
    end

    context "thread_b acquires; thread_b releases; thread_a acquires; thread_a releases" do
      it "satisfies the protocol" do
        expect(
          protocol.satisfied_by? do
            thread_b.acquire_lock
            thread_b.release_lock
            thread_a.acquire_lock
            thread_a.release_lock
          end
        ).to be true
      end
    end

    context "thread_a acquires; thread_b acquires; thread_a releases; thread_b releases" do
      it "doesn't satisfy the protocol" do
        expect(
          protocol.satisfied_by? do
            thread_a.acquire_lock
            thread_b.acquire_lock
            thread_a.release_lock
            thread_b.release_lock
          end
        ).to be false
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
