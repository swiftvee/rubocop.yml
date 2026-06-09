module RuboCop
  module Cops
    module Custom
      # Disallow the loose be_truthy and be_falsey matchers in specs.
      class DisallowBeTruthyBeFalsey < ::RuboCop::Cop::Base
        MSG = "Do not use %<matcher>s; assert the exact value instead (e.g. be(true) or be(false)).".freeze

        DISALLOWED = %i[be_truthy be_falsey].freeze

        def on_send(node)
          return unless DISALLOWED.include?(node.method_name)
          return unless node.receiver.nil?

          add_offense(node.loc.selector, message: format(MSG, matcher: node.method_name))
        end

        alias_method :on_csend, :on_send
      end
    end
  end
end
