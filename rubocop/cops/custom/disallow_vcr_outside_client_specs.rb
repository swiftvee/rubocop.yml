module RuboCop
  module Cops
    module Custom
      # Disallow using VCR cassettes outside of spec/clients.
      class DisallowVcrOutsideClientSpecs < ::RuboCop::Cop::Base
        MSG = "Only use VCR cassettes in spec/clients.".freeze

        ALLOWED_PATH = %r{(\A|/)spec/clients/}

        CASSETTE_METHODS = %i[use_cassette insert_cassette].freeze

        EXAMPLE_METHODS = %i[
          describe context example_group
          it specify example
          feature scenario
          fdescribe fcontext fit fspecify ffeature fscenario
          xdescribe xcontext xit xspecify xfeature xscenario
          shared_examples shared_context shared_examples_for
        ].freeze

        def on_send(node)
          return if allowed_file?

          flag_cassette_call(node)
          flag_vcr_metadata(node)
        end

        private

        def flag_cassette_call(node)
          return unless node.receiver&.const_type? && node.receiver.const_name == "VCR"
          return unless CASSETTE_METHODS.include?(node.method_name)

          add_offense(node)
        end

        def flag_vcr_metadata(node)
          return unless EXAMPLE_METHODS.include?(node.method_name)

          node.arguments.each do |argument|
            if argument.sym_type? && argument.value == :vcr
              add_offense(argument)
            elsif argument.hash_type?
              argument.pairs.each do |pair|
                add_offense(pair.key) if pair.key.sym_type? && pair.key.value == :vcr
              end
            end
          end
        end

        def allowed_file?
          ALLOWED_PATH.match?(processed_source.buffer.name)
        end
      end
    end
  end
end
