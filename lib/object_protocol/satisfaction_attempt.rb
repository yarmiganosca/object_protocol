require 'object_protocol/execution'

class ObjectProtocol
  class SatisfactionAttempt
    def initialize(protocol, &blk)
      @protocol = protocol
      @blk      = blk
    end

    def to_bool
      execution.call(protocol)

      execution.messages.each do |sent_message|
        break if satisfied?

        next_unsatisfied_expectation = satisfiable_expectations.find(&:unsatisfied?)

        next_unsatisfied_expectation.attempt_to_apply_sent_message(sent_message)
      end

      satisfied?
    end

    def satisfied?
      satisfiable_expectations.all?(&:satisfied?)
    end

    def unsatisfied?
      !satisfied?
    end

    def to_rspec_matcher_failure_message_lines
      return ["<empty execution>"] if execution.messages.empty?

      execution.messages.map do |sent_message|
        fragment_base = "#{protocol.name_of_participant(sent_message.sender)}"\
          ".sent(:#{sent_message.name})"\
          ".to(#{protocol.name_of_participant(sent_message.receiver)})"

        if sent_message.arguments_passed?
          "#{fragment_base}.with(#{sent_message.arguments})"
        else
          fragment_base
        end
      end
    end

    private

    attr_reader :protocol, :blk

    def satisfiable_expectations
      @satisfiable_expectations ||= protocol.expectations.map(&:to_satisfiable)
    end

    def execution
      @execution ||= Execution.new(*protocol.participants, &blk)
    end
  end
end
