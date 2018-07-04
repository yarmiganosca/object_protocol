require 'binding_of_caller'

require 'object_protocol/sent_message'

class ObjectProtocol
  class Execution
    attr_reader :participants

    def initialize(*participants, &blk)
      raise(ArgumentError, "#{self.class.name} requires a block") unless block_given?

      @participants = participants
      @blk          = blk
    end

    def call(protocol)
      begin
        $object_protocol_spying_enabled = false
        participants.each(&method(:start_spying_on_public_methods_on))
        # we guard inside the methods with a global so that we don't start spying
        # while we're still redefining all the public methods on the participant
        $object_protocol_spying_enabled = true
        protocol.instance_exec(&blk)
      ensure
        $object_protocol_spying_enabled = false
        participants.each(&method(:stop_spying_on_public_methods_on))
      end
    end

    def messages; @messages ||= []; end

    private

    attr_reader :blk

    def start_spying_on_public_methods_on(participant)
      execution         = self
      methods_to_spy_on = participant.methods - %i(object_id __send__) # to avoid warnings

      participant.instance_exec {
        @methods_by_name ||= {}
      }

      participant_object_ids = self.participants.map(&:object_id)

      methods_to_spy_on.each do |method_name|
        method = participant.method(method_name)

        participant.instance_variable_get(:@methods_by_name)[method_name] = method

        method_body = proc do |*args, &blk|
          if $object_protocol_spying_enabled
            sender_object_id = binding.of_caller(1).eval("object_id")

            # if we try participants.include?(sender), we end up with a lot more
            # recorded messages because of equality checking
            if participant_object_ids.include?(sender_object_id)
              sender    = ObjectSpace._id2ref(sender_object_id)
              arguments = if block_given?
                            [args, blk]
                          else
                            args
                          end

              sent_message = SentMessage.new(
                sender:   sender,
                receiver: self,
                name:     method_name,
              )

              sent_message.with(arguments) if arguments.any?

              execution.messages << sent_message
            end
          end

          method.call(*args, &blk)
        end

        participant.instance_eval("undef #{method_name}")

        if method_name == :define_singleton_method
          method.call(method_name, &method_body)
        else
          participant.define_singleton_method(method_name, &method_body)
        end
      end
    end

    def stop_spying_on_public_methods_on(participant)
      participant.instance_variable_get(:@methods_by_name).each do |method_name, method|
        participant.instance_eval("undef #{method_name}")

        if method_name == :define_singleton_method # define_singleton_method has just been undefined
          method.call(method_name, &method)
        else
          participant.define_singleton_method(method_name, &method)
        end
      end
    end
  end
end
