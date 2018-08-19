require 'object_protocol/satisfiable_message_sequence_expectation_base'

class ObjectProtocol
  class SatisfiableOrderedMessageSequenceExpectation < SatisfiableMessageSequenceExpectationBase
    def attempt_to_apply_sent_message(sent_message)
      return if satisfied?

      next_unsatisfied_expectation = satisfiable_expectations.find(&:unsatisfied?)

      next_unsatisfied_expectation.attempt_to_apply_sent_message(sent_message)
    end

    private

    def inspect_name
      "in_order"
    end
  end
end
