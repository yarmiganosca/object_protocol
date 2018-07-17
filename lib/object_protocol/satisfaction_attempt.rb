require 'object_protocol/execution'

class ObjectProtocol
  class SatisfactionAttempt
    def initialize(protocol, &blk)
      @protocol = protocol
      @blk      = blk
    end

    def to_bool
      execution.call(protocol)

      satisfiable_expectations = protocol.expectations.map(&:to_satisfiable)

      execution.messages.each do |sent_message|
        next_expectation = satisfiable_expectations.first

        next_expectation.attempt_to_apply_sent_message(sent_message)

        if next_expectation.satisfied?
          satisfiable_expectations.shift
        end
      end

      satisfiable_expectations.empty?
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

    def execution
      @execution ||= Execution.new(*protocol.participants, &blk)
    end
  end
end
