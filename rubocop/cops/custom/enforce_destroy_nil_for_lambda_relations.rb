module RuboCop
  module Cops
    module Custom
      # Enforce destroy: nil on scoped has_one/has_many associations.
      class EnforceDestroyNilForLambdaRelations < ::RuboCop::Cop::Base
        MSG = "Associations with a lambda scope must set destroy: nil.".freeze

        def on_send(node)
          return unless association_with_lambda_scope?(node)
          return if destroy_nil_option?(node)

          add_offense(node.loc.selector, message: MSG)
        end

        private

        def association_with_lambda_scope?(node)
          return false unless node.method?(:has_one) || node.method?(:has_many)

          node.arguments.any? { |argument| argument.block_type? && argument.lambda? }
        end

        def destroy_nil_option?(node)
          options_hash = node.arguments.last
          return false unless options_hash&.hash_type?

          options_hash.pairs.any? do |pair|
            pair.key.sym_type? && pair.key.value == :destroy && pair.value.nil_type?
          end
        end
      end
    end
  end
end
