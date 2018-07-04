class ObjectProtocol
  class SentMessage
    attr_reader :sender, :receiver, :name, :arguments

    def initialize(sender:, receiver:, name:)
      @sender   = sender
      @receiver = receiver
      @name     = name

      @arguments_passed = false
    end

    def arguments_passed?
      !!@arguments_passed
    end

    def with(arguments)
      @arguments = arguments

      @arguments_passed = true

      self
    end

    def inspect
      "<#{self.class.name}[#{sender.class.name}, :#{name}, #{receiver.class.name}]>"
    end

    def ==(other)
      other.respond_to?(:sender) &&
        sender == other.sender &&
        other.respond_to?(:receiver) &&
        receiver == other.receiver &&
        other.respond_to?(:name) &&
        name == other.name &&
        other.respond_to?(:arguments) &&
        arguments == other.arguments
    end
  end
end
