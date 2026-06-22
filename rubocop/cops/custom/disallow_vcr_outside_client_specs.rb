module RuboCop
  module Cops
    module Custom
      # Disallow using VCR cassettes outside of spec/clients.
      class DisallowVcrOutsideClientSpecs < ::RuboCop::Cop::Base
        MSG = "Only use VCR cassettes in spec/clients.".freeze

        ALLOWED_PATH = %r{(\A|/)spec/clients/}

        CASSETTE_METHODS = %i[use_cassette insert_cassette].freeze

        def on_send(node)
          return if allowed_file?
          return unless node.receiver&.const_type? && node.receiver.const_name == "VCR"
          return unless CASSETTE_METHODS.include?(node.method_name)

          add_offense(node)
        end

        def on_sym(node)
          return if allowed_file?
          return unless node.value == :vcr

          add_offense(node)
        end

        private

        def allowed_file?
          ALLOWED_PATH.match?(processed_source.buffer.name)
        end
      end
    end
  end
end
