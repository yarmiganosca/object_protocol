require 'forwardable'

class ObjectProtocol
  class SatisfiableOrderedMessageSequenceExpectation
    def initialize(protocol:, sequence_expectation:)
      @protocol             = protocol
      @sequence_expectation = sequence_expectation
    end

    def attempt_to_apply_sent_message(sent_message)
      return if satisfied?

      next_unsatisfied_expectation = satisfiable_expectations.find(&:unsatisfied?)

      next_unsatisfied_expectation.attempt_to_apply_sent_message(sent_message)
    end

    def satisfied?
      satisfiable_expectations.all?(&:satisfied?)
    end

    def unsatisfied?
      !satisfied?
    end

    def partially_but_not_fully_satisfied?
      satisfiable_expectations.any?(&:satisfied?) && unsatisfied?
    end

    def inspect
      status = satisfied? ? "(satisfied)" : "(unsatisfied)"

      [
        "in_order #{status}",
        *satisfiable_expectations.map(&:inspect)
          .join("\n")
          .split("\n")
          .map(&"  ".method(:+))
      ].join("\n")
    end

    private

    attr_reader :protocol, :sequence_expectation

    def satisfiable_expectations
      @satisfiable_expectations ||= sequence_expectation.expectations.map(&:to_satisfiable)
    end
  end
end
