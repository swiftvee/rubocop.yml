module RuboCop
  module Cops
    module Custom
      # Disallow naming a `let` or `subject` in a helper spec after a method under test. A helper
      # spec mixes the described helper into the example context, so the binding shadows the real
      # method: a bare call returns the memoized value, and a call with arguments raises
      # ArgumentError naming neither the helper nor the binding.
      class DisallowShadowedHelperMethod < ::RuboCop::Cop::Base
        MSG = "Do not name a let or subject after the method under test; it shadows the helper.".freeze

        HELPER_SPEC_PATH = %r{(\A|/)spec/helpers/}

        BINDING_METHODS = %i[let let! subject].freeze

        EXAMPLE_GROUP_METHODS = %i[describe context].freeze

        DESCRIBED_METHOD = /\A#([a-z_][a-zA-Z0-9_]*[?!]?)\z/

        def on_new_investigation
          @described_methods = nil
        end

        def on_send(node)
          return unless helper_spec?
          return unless BINDING_METHODS.include?(node.method_name)
          return unless node.receiver.nil?

          argument = node.first_argument
          return unless argument&.sym_type?
          return unless described_methods.include?(argument.value.to_s)

          add_offense(argument, message: MSG)
        end

        private

        # `describe "#formatted_address"` names an instance method of the helper under test, which
        # is what the example context carries. A `".class_method"` describe does not.
        def described_methods
          @described_methods ||=
            processed_source.ast.each_node(:send).filter_map do |node|
              next unless EXAMPLE_GROUP_METHODS.include?(node.method_name) && node.receiver.nil?

              argument = node.first_argument
              argument.value[DESCRIBED_METHOD, 1] if argument&.str_type?
            end
        end

        def helper_spec?
          HELPER_SPEC_PATH.match?(processed_source.buffer.name)
        end
      end
    end
  end
end
