require 'forwardable'

class ObjectProtocol
  class SatisfiableUnorderedMessageSequenceExpectation
    def initialize(protocol:, sequence_expectation:)
      @protocol             = protocol
      @sequence_expectation = sequence_expectation
    end

    def attempt_to_apply_sent_message(sent_message)
      return if satisfied?

      if started_to_satisfy_one_expectation?
        continue_attempting_to_satisfy_partially_satisfied_expectation(sent_message)
      else
        attempt_to_satisfy_any_satisfiable_expectation(sent_message)
      end
    end

    private def started_to_satisfy_one_expectation?
              satisfiable_expectations.any?(&:partially_but_not_fully_satisfied?)
            end

    private def continue_attempting_to_satisfy_partially_satisfied_expectation(sent_message)
              satisfiable_expectations
                .find(&:partially_but_not_fully_satisfied?)
                .attempt_to_apply_sent_message(sent_message)
            end

    private def attempt_to_satisfy_any_satisfiable_expectation(sent_message)
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

    def unsatisfied?
      !satisfied?
    end

    def partially_but_not_fully_satisfied?
      satisfiable_expectations.any?(&:satisfied?) && unsatisfied?
    end

    def inspect
      status = satisfied? ? "(satisfied)" : "(unsatisfied)"

      [
        "in_any_order #{status}",
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
