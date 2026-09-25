module RuboCop
  module Cops
    module Custom
      # Require the `validate` option on `enum` and `native_enum` declarations, so an unknown value is a validation error
      # rather than an `ArgumentError` on assignment. StoreModel enums (`in:`) do not take the option.
      class EnforceEnumValidate < ::RuboCop::Cop::Base
        MSG = "Declare enum with `validate: true` or `validate: { ... }`.".freeze

        ENUM_METHODS = %i[enum native_enum].freeze

        def on_send(node)
          return unless ENUM_METHODS.include?(node.method_name)
          return unless node.receiver.nil?
          return if node.arguments.empty?
          return if store_model_enum?(node.last_argument)
          return if validate?(node.last_argument)

          add_offense(node.loc.selector, message: MSG)
        end

        alias_method :on_csend, :on_send

        private

        def store_model_enum?(argument)
          option?(argument, :in)
        end

        def validate?(argument)
          option?(argument, :validate) { |value| value.true_type? || value.hash_type? }
        end

        def option?(argument, key)
          return false unless argument.hash_type?

          argument.pairs.any? { |pair| pair.key.sym_type? && pair.key.value == key && (!block_given? || yield(pair.value)) }
        end
      end
    end
  end
end
