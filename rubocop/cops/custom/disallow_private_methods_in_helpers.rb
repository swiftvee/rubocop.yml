module RuboCop
  module Cops
    module Custom
      # Disallow private visibility declarations in helper modules.
      class DisallowPrivateMethodsInHelpers < ::RuboCop::Cop::Base
        MSG = "Do not define private helper methods in app/helpers. Keep helper methods public.".freeze

        def on_send(node)
          return unless helper_file?
          return unless node.receiver.nil?
          return unless node.method?(:private)

          add_offense(node.loc.selector, message: MSG)
        end

        private

        def helper_file?
          processed_source.buffer.name.include?("app/helpers/")
        end
      end
    end
  end
end
