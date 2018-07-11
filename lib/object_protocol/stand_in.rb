require 'object_protocol/expected_message'

class ObjectProtocol
  class StandIn
    attr_reader :name

    def initialize(protocol:, name:)
      @protocol = protocol
      @name     = name
    end

    def sends(message)
      ExpectedMessage.new(sender: self, message: message).tap do |expected_message|
        protocol.expected_messages << expected_message
      end
    end

    private

    attr_reader :protocol
  end
end
