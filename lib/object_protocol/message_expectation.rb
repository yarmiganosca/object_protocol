class ObjectProtocol
  class MessageExpectation
    attr_reader :protocol, :sender, :message, :receiver, :arguments

    def initialize(protocol:, sender:, message:)
      @protocol = protocol
      @sender   = sender
      @message  = message

      @arguments_specified = false
    end

    def to(receiver)
      @receiver = receiver

      self
    end

    def with(*arguments)
      @arguments = arguments

      @arguments_specified = true

      self
    end

    def to_satisfiable
      SatisfiableMessageExpectation.new(protocol: protocol, message_expectation: self)
    end

    def inspect
      "<#{self.class.name.split('::').last}[#{sender.name}, :#{message}, #{receiver.name}]>"
    end

    def to_rspec_matcher_failure_message_line
      fragment_base = "#{sender.name}.sends(:#{message}).to(#{receiver.name})"

      if arguments_specified?
        "#{fragment_base}.with(#{arguments})"
      else
        fragment_base
      end
    end

    def ==(other)
      other.respond_to?(:sender) &&
        sender == other.sender &&
        other.respond_to?(:receiver) &&
        receiver == other.receiver &&
        other.respond_to?(:message) &&
        message == other.message &&
        other.respond_to?(:arguments) &&
        arguments == other.arguments
    end

    def arguments_specified?
      @arguments_specified
    end
  end
end
