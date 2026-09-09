module RuboCop
  module Cops
    module Custom
      # Require every class in app/services to carry a `Service` suffix.
      class EnforceServiceClassSuffix < ::RuboCop::Cop::Base
        MSG = "Name a class in app/services with a Service suffix.".freeze

        SERVICES_PATH = %r{(\A|/)app/services/}

        EXCEPTION_SUFFIXES = %w[Error Exception].freeze

        def on_class(node)
          return unless service_file?
          return if exception_class?(node)
          return if node.identifier.short_name.to_s.end_with?("Service")

          add_offense(node.identifier, message: MSG)
        end

        private

        # A service raises its own failures, and those classes are named after what went wrong.
        def exception_class?(node)
          superclass = node.parent_class
          return false unless superclass&.const_type?

          superclass.short_name.to_s.end_with?(*EXCEPTION_SUFFIXES)
        end

        def service_file?
          SERVICES_PATH.match?(processed_source.buffer.name)
        end
      end
    end
  end
end
