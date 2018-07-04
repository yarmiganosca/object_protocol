require 'object_protocol/step'

class ObjectProtocol
  class StandIn
    attr_reader :name

    def initialize(protocol:, name:)
      @protocol = protocol
      @name     = name
    end

    def sends(message)
      Step.new(sender: self, message: message).tap do |step|
        protocol.steps << step
      end
    end

    private

    attr_reader :protocol
  end
end
