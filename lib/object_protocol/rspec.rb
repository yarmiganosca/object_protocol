require 'object_protocol'

require 'rspec/core'
require 'rspec/expectations'

class SatisfactionAttemptVerifier
  def initialize(&blk)
    @blk = blk
  end

  def matches?(protocol)
    @protocol = protocol
    @attempt  = ObjectProtocol::SatisfactionAttempt.new(protocol, &blk)

    attempt.to_bool
  end

  def failure_message
    [
      "expected",
      protocol.to_rspec_matcher_failure_message_lines.map(&"  ".method(:+)).flatten,
      "to be satisfied by",
      attempt.to_rspec_matcher_failure_message_lines.map(&"  ".method(:+)).flatten,
    ].join("\n")
  end

  private

  attr_reader :blk, :protocol, :attempt
end

module ObjectProtocol::RSpecMatchers
  def be_satisfied_by(&blk)
    SatisfactionAttemptVerifier.new(&blk)
  end
end

RSpec.configure do |config|
  config.include ObjectProtocol::RSpecMatchers
end
