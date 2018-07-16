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
      ).tap do |message_expectation|
        protocol.expectations << message_expectation
      end
    end

    private

    attr_reader :protocol
  end
end
