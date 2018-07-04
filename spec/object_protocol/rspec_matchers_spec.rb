require 'object_protocol/rspec'

require 'rspec/matchers/fail_matchers'

RSpec.configure { |config| config.include RSpec::Matchers::FailMatchers }

RSpec.describe "expect(protocol).to be_satisfied_by { ... }" do
  context "with a simple logging procotol" do
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
        logger.sends(:<<).to(device)
      end.bind(
        device: device,
        logger: Logger.new(device),        
      )
    end

    context 'when the execution forces the logger to append to the device' do
      it "passes" do
        expect(protocol).to be_satisfied_by { logger.info("message") }
      end
    end

    context "an empty execution" do
      it "fails" do
        expect {
          expect(protocol).to be_satisfied_by {}
        }.to fail_with([
          "expected",
          "  logger.sends(:<<).to(device)",
          "to be satisfied by",
          "  <empty execution>",
        ].join("\n"))
      end
    end

    context "an incorrect execution" do
      it "fails with a useful message" do
        expect {
          expect(protocol).to be_satisfied_by { logger.rotate }
        }.to fail_with([
          "expected",
          "  logger.sends(:<<).to(device)",
          "to be satisfied by",
          "  logger.sent(:shift).to(device)",
        ].join("\n"))
      end
    end
  end
end
