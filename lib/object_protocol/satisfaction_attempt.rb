require 'object_protocol/execution'
require 'object_protocol/message_expectation'

class ObjectProtocol
  class SatisfactionAttempt
    def initialize(protocol, &blk)
      @protocol = protocol
      @blk      = blk
    end

    def to_bool
      execution.call(protocol)

      message_expectations = protocol.expected_messages.map do |expected_message|
        MessageExpectation.new(protocol: protocol, expected_message: expected_message)
      end

      execution.messages.each do |sent_message|
        next_message_expectation = message_expectations.first

        next_message_expectation.attempt_to_apply_sent_message(sent_message)

        if next_message_expectation.satisfied?
          message_expectations.shift
        end
      end

      message_expectations.empty?
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
