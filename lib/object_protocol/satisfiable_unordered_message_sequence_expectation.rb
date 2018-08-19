require 'object_protocol/satisfiable_message_sequence_expectation_base'

class ObjectProtocol
  class SatisfiableUnorderedMessageSequenceExpectation < SatisfiableMessageSequenceExpectationBase
    def attempt_to_apply_sent_message(sent_message)
      return if satisfied?

      if started_to_satisfy_one_expectation?
        continue_attempting_to_satisfy_partially_satisfied_expectation(sent_message)
      else
        attempt_to_satisfy_any_satisfiable_expectation(sent_message)
      end
    end

    private

    def started_to_satisfy_one_expectation?
      satisfiable_expectations.any?(&:partially_but_not_fully_satisfied?)
    end

    def continue_attempting_to_satisfy_partially_satisfied_expectation(sent_message)
      satisfiable_expectations
        .find(&:partially_but_not_fully_satisfied?)
        .attempt_to_apply_sent_message(sent_message)
    end

    def attempt_to_satisfy_any_satisfiable_expectation(sent_message)
      satisfiable_expectations.each do |satisfiable_expectation|
        if satisfiable_expectation.unsatisfied?
          satisfiable_expectation.attempt_to_apply_sent_message(sent_message)

          break if satisfiable_expectation.satisfied?
        end
      end
    end

    def inspect_name
      "in_any_order"
    end
  end
end
