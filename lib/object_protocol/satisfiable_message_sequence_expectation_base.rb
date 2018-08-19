class ObjectProtocol
  class SatisfiableMessageSequenceExpectationBase
    def initialize(protocol:, sequence_expectation:)
      @protocol             = protocol
      @sequence_expectation = sequence_expectation
    end

    def attempt_to_apply_sent_message(sent_message)
      raise NotImplementedError
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
        "#{inspect_name} #{status}",
        *satisfiable_expectations.map(&:inspect)
          .join("\n")
          .split("\n")
          .map(&"  ".method(:+))
      ].join("\n")
    end

    private

    attr_reader :protocol, :sequence_expectation

    def inspect_name
      raise NotImplementedError
    end

    def satisfiable_expectations
      @satisfiable_expectations ||= sequence_expectation.expectations.map(&:to_satisfiable)
    end    
  end
end
