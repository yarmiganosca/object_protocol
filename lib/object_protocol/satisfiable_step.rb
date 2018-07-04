require 'forwardable'

class ObjectProtocol
  class SatisfiableStep
    extend Forwardable

    delegate %i(sender receiver message arguments arguments_specified?) => :@step

    def initialize(protocol:, step:)
      @protocol = protocol
      @step     = step

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

    private

    attr_reader :protocol
  end
end
