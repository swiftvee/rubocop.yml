module RuboCop
  module Cops
    module Custom
      # Disallow describe "#resolve" blocks in policy specs. A Pundit scope has one public method, so
      # the group repeats the describe described_class::Scope around it.
      class DisallowDescribeResolve < ::RuboCop::Cop::Base
        MSG = 'Do not use describe "#resolve" blocks.'.freeze

        POLICY_SPEC_PATH = %r{(\A|/)spec/policies/}

        def_node_matcher :describe_resolve_block?, <<~PATTERN
          (send nil? :describe (str "#resolve") ...)
        PATTERN

        def on_send(node)
          return unless policy_spec?
          return unless describe_resolve_block?(node)

          add_offense(node, message: MSG)
        end

        private

        def policy_spec?
          POLICY_SPEC_PATH.match?(processed_source.buffer.name)
        end
      end
    end
  end
end
