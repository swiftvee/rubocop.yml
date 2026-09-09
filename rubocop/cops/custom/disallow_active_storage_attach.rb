module RuboCop
  module Cops
    module Custom
      # Disallow ActiveStorage `attach`, which saves the record with `save` and returns nil
      # instead of raising when a validation fails.
      class DisallowActiveStorageAttach < ::RuboCop::Cop::Base
        MSG = "Assign the attachment as an attribute instead of calling attach.".freeze

        def on_send(node)
          flag_attach_call(node)
          flag_attach_reference(node)
        end

        alias_method :on_csend, :on_send

        private

        # An attachment relation is always the receiver (`lot.images.attach`), so a receiverless
        # `attach` is a call to something else, such as a controller action of that name.
        def flag_attach_call(node)
          return if node.receiver.nil?
          return unless node.method?(:attach)

          add_offense(node.loc.selector)
        end

        def flag_attach_reference(node)
          return unless node.method?(:method)

          argument = node.first_argument
          return unless argument&.sym_type? && argument.value == :attach

          add_offense(argument)
        end
      end
    end
  end
end
