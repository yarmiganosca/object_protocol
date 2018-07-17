require "object_protocol/version"
require 'object_protocol/stand_in'
require 'object_protocol/satisfaction_attempt'
require 'object_protocol/unordered_message_sequence_expectation'

class ObjectProtocol
  attr_reader :participants_by_name

  def initialize(*participant_names, &expectations)
    participant_names.each(&method(:define_stand_in))
    instance_exec(&expectations)
    participant_names.each(&method(:undefine_stand_in))
  end

  def in_any_order(&expectations)
    unordered_message_sequence_expectation = UnorderedMessageSequenceExpectation.new(protocol: self)
    self.expectations << unordered_message_sequence_expectation

    expectation_sequence_stack.push(unordered_message_sequence_expectation)
    instance_exec(&expectations)
    expectation_sequence_stack.pop
  end

  def bind(**participants_by_name)
    @participants_by_name = participants_by_name

    @participants_by_name.each(&method(:define_participant))

    self
  end

  def satisfied_by?(&blk)
    SatisfactionAttempt.new(self, &blk).to_bool
  end

  def add_expectation(expectation)
    expectation_sequence_stack.last.expectations << expectation
  end

  def expectations
    @expectations ||= []
  end

  def participant_by_name(name)
    participants_by_name[name]
  end

  def name_of_participant(participant)
    participants_by_name.invert[participant]
  end

  def participants
    participants_by_name.values
  end

  def to_rspec_matcher_failure_message_lines
    expectations.flat_map(&:to_rspec_matcher_failure_message_lines)
  end

  private

  def define_participant(name, participant)
    instance_variable_set("@#{name}_participant", participant)

    define_singleton_method(name) do
      instance_variable_get("@#{name}_participant")
    end
  end

  def define_stand_in(name)
    instance_variable_set("@#{name}_stand_in", StandIn.new(protocol: self, name: name))

    define_singleton_method(name) do
      instance_variable_get("@#{name}_stand_in")
    end
  end

  def undefine_stand_in(name)
    instance_eval("undef :#{name}")
    remove_instance_variable("@#{name}_stand_in")
  end

  def expectation_sequence_stack
    @expectation_sequence_stack ||= [self]
  end
end
