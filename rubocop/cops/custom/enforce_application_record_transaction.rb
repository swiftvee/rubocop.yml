module RuboCop
  module Cops
    module Custom
      # Enforce using ApplicationRecord.transaction for transaction blocks.
      class EnforceApplicationRecordTransaction < ::RuboCop::Cop::Base
        MSG = "Use ApplicationRecord.transaction for transaction blocks.".freeze

        def on_send(node)
          return unless node.method?(:transaction)
          return unless transaction_block_call?(node)
          return if application_record_receiver?(node.receiver)

          add_offense(node.loc.selector, message: MSG)
        end

        alias on_csend on_send

        private

        def application_record_receiver?(receiver)
          return false unless receiver&.const_type?

          ["ApplicationRecord", "::ApplicationRecord"].include?(receiver.const_name)
        end

        def transaction_block_call?(node)
          parent = node.parent

          parent&.block_type? && parent.send_node.equal?(node)
        end
      end
    end
  end
end