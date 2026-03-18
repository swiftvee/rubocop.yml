module RuboCop
  module Cops
    module Custom
      # Prevent synchronous mail delivery in application code.
      class DisallowDeliverNow < ::RuboCop::Cop::Base
        extend ::RuboCop::Cop::AutoCorrector

        MSG = "Use deliver_later instead of deliver_now.".freeze

        def on_send(node)
          return if spec_file?
          return unless node.method?(:deliver_now)

          add_offense(node.loc.selector, message: MSG) do |corrector|
            corrector.replace(node.loc.selector, "deliver_later")
          end
        end

        alias on_csend on_send

        private

        def spec_file?
          processed_source.buffer.name.end_with?("_spec.rb")
        end
      end
    end
  end
end
