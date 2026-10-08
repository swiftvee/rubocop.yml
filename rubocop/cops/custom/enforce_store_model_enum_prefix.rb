module RuboCop
  module Cops
    module Custom
      # Require `_prefix: true` on StoreModel enum declarations (`enum :type, in: ...`). ActiveRecord enums are
      # declared with `native_enum`, which passes `prefix: true` itself, and `enum` without `in:` is left to
      # Custom/DisallowDefaultEnum.
      class EnforceStoreModelEnumPrefix < ::RuboCop::Cop::Base
        MSG = "Declare StoreModel enum with `_prefix: true`.".freeze

        def on_send(node)
          return unless node.method?(:enum) && node.receiver.nil?

          options = node.last_argument
          return unless options&.hash_type? && store_model_values?(options)
          return if prefix_true?(options)

          add_offense(node.loc.selector, message: MSG)
        end

        alias_method :on_csend, :on_send

        private

        def store_model_values?(options)
          options.pairs.any? { |pair| pair.key.sym_type? && pair.key.value == :in }
        end

        def prefix_true?(options)
          options.pairs.any? { |pair| pair.key.sym_type? && pair.key.value == :_prefix && pair.value.true_type? }
        end
      end
    end
  end
end
