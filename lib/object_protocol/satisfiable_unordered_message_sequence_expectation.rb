require 'forwardable'

class ObjectProtocol
  class SatisfiableUnorderedMessageSequenceExpectation
    extend Forwardable

    def initialize(protocol:, sequence_expectation:)
      @protocol             = protocol
      @sequence_expectation = sequence_expectation
    end

    def attempt_to_apply_sent_message(sent_message)
      return if satisfied?

      satisfiable_expectations.each do |satisfiable_expectation|
        if satisfiable_expectation.unsatisfied?
          satisfiable_expectation.attempt_to_apply_sent_message(sent_message)

          break if satisfiable_expectation.satisfied?
        end
      end
    end

    def satisfied?
      satisfiable_expectations.all?(&:satisfied?)
    end

    private

    attr_reader :protocol, :sequence_expectation

    def satisfiable_expectations
      @satisfiable_expectations ||= sequence_expectation.expectations.map(&:to_satisfiable)
    end
  end
end
