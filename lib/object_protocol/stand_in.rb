require 'object_protocol/message_expectation'

class ObjectProtocol
  class StandIn
    attr_reader :name

    def initialize(protocol:, name:)
      @protocol = protocol
      @name     = name
    end

    def sends(message)
      MessageExpectation.new(
        protocol: protocol,
        sender:   self,
        message:  message
      ).tap(&protocol.method(:add_expectation))
    end

    private

    attr_reader :protocol
  end
end
