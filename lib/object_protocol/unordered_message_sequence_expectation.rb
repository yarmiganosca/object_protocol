require 'object_protocol/satisfiable_unordered_message_sequence_expectation'

class ObjectProtocol
  class UnorderedMessageSequenceExpectation
    def initialize(protocol:)
      @protocol = protocol
    end

    def expectations
      @expectations ||= []
    end

    def to_rspec_matcher_failure_message_lines
      [
        "in_any_order",
        *expectations.flat_map(&:to_rspec_matcher_failure_message_lines).map(&"  ".method(:+)),
      ]
    end

    def to_satisfiable
      SatisfiableUnorderedMessageSequenceExpectation.new(
        protocol:             protocol,
        sequence_expectation: self
      )
    end

    private

    attr_reader :protocol
  end
end
