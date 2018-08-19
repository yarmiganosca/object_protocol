require 'forwardable'

module Protocols
  module CriticalSection
    def self.new
      ObjectProtocol.new(:lock, :thread_a, :thread_b) do
        in_any_order do
          in_order do
            thread_a.sends(:lock).to(lock)
            thread_a.sends(:unlock).to(lock)
          end

          in_order do
            thread_b.sends(:lock).to(lock)
            thread_b.sends(:unlock).to(lock)
          end
        end
      end
    end

    class Thread
      extend Forwardable

      def initialize(lock:)
        @lock = lock
      end

      def_delegator :@lock, :lock, :acquire_lock
      def_delegator :@lock, :unlock, :release_lock
    end

    class Lock
      def lock; end
      def unlock; end
    end
  end
end
