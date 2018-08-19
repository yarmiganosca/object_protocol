require 'forwardable'

class ObjectProtocol
  class SatisfiableMessageExpectation
    extend Forwardable

    delegate %i(sender receiver message arguments arguments_specified?) => :@message_expectation

    def initialize(protocol:, message_expectation:)
      @protocol            = protocol
      @message_expectation = message_expectation

      @satisfied = false
    end

    def attempt_to_apply_sent_message(sent_message)
      return if satisfied?
      return false unless is_sent_message_applicable?(sent_message)

      @satisfied = true
    end

    def is_sent_message_applicable?(sent_message)
      return false unless protocol.participant_by_name(sender.name) == sent_message.sender
      return false unless protocol.participant_by_name(receiver.name) == sent_message.receiver
      return false unless message == sent_message.name

      if arguments_specified?
        return false unless arguments == sent_message.arguments
      end

      true
    end

    def satisfied?
      !!@satisfied
    end

    def unsatisfied?
      !satisfied?
    end

    def partially_but_not_fully_satisfied?
      false
    end

    def inspect
      status = satisfied? ? "(satisfied)" : "(unsatisfied)"

      "#{sender.name}, :#{message}, #{receiver.name} #{status}"
    end

    private

    attr_reader :protocol
  end
end
