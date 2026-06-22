module RuboCop
  module Cops
    module Custom
      # Prevent using the default Rails `enum` in models in favour of `native_enum`.
      class DisallowDefaultEnum < ::RuboCop::Cop::Base
        MSG = "Use native_enum instead of the default enum.".freeze

        def on_send(node)
          return unless node.method?(:enum)
          return unless node.receiver.nil?
          return if node.arguments.empty?

          add_offense(node.loc.selector, message: MSG)
        end

        alias_method :on_csend, :on_send
      end
    end
  end
end
