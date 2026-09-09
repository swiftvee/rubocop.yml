module RuboCop
  module Cops
    module Custom
      # Disallow describe "#perform" blocks in specs.
      class DisallowDescribePerform < ::RuboCop::Cop::Base
        MSG = 'Do not use describe "#perform" blocks.'.freeze

        def_node_matcher :describe_perform_block?, <<~PATTERN
          (send nil? :describe (str "#perform") ...)
        PATTERN

        def on_send(node)
          return unless describe_perform_block?(node)

          add_offense(node, message: MSG)
        end
      end
    end
  end
end
