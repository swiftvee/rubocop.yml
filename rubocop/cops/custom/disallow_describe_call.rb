module RuboCop
  module Cops
    module Custom
      # Disallow describe "#call" blocks in specs.
      class DisallowDescribeCall < ::RuboCop::Cop::Base
        MSG = 'Do not use describe "#call" blocks.'.freeze

        def_node_matcher :describe_call_block?, <<~PATTERN
          (send nil? :describe (str "#call") ...)
        PATTERN

        def on_send(node)
          return unless describe_call_block?(node)

          add_offense(node.loc.expression, message: MSG)
        end
      end
    end
  end
end
