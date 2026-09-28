module RuboCop
  module Cops
    module Custom
      # Disallow describe "#resolve" blocks in specs.
      class DisallowDescribeResolve < ::RuboCop::Cop::Base
        MSG = 'Do not use describe "#resolve" blocks.'.freeze

        def_node_matcher :describe_resolve_block?, <<~PATTERN
          (send nil? :describe (str "#resolve") ...)
        PATTERN

        def on_send(node)
          return unless describe_resolve_block?(node)

          add_offense(node, message: MSG)
        end
      end
    end
  end
end
