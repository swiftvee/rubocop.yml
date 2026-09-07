module RuboCop
  module Cops
    module Custom
      # Require `prefix: true` on `enum` and `native_enum` declarations (`_prefix: true` for StoreModel enums).
      class EnforceEnumPrefix < ::RuboCop::Cop::Base
        MSG = "Declare enum with `prefix: true`.".freeze

        ENUM_METHODS = %i[enum native_enum].freeze

        def on_send(node)
          return unless ENUM_METHODS.include?(node.method_name)
          return unless node.receiver.nil?
          return if node.arguments.empty?
          return if prefix_true?(node.last_argument)

          add_offense(node.loc.selector, message: MSG)
        end

        alias_method :on_csend, :on_send

        private

        def prefix_true?(argument)
          return false unless argument.hash_type?

          argument.pairs.any? { |pair| pair.key.sym_type? && %i[prefix _prefix].include?(pair.key.value) && pair.value.true_type? }
        end
      end
    end
  end
end
