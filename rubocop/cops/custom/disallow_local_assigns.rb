module RuboCop
  module Cops
    module Custom
      # Disallow local_assigns usage in views/partials.
      class DisallowLocalAssigns < ::RuboCop::Cop::Base
        MSG = "Do not use local_assigns.".freeze

        def on_send(node)
          return unless node.method?(:local_assigns)

          add_offense(node.loc.selector, message: MSG)
        end

        alias_method :on_csend, :on_send
      end
    end
  end
end
