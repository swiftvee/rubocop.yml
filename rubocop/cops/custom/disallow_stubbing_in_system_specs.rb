module RuboCop
  module Cops
    module Custom
      # Disallows mocking/stubbing inside system specs.
      #
      # This cop warns if you call `allow`, `expect`, `.stub`, or similar methods
      # inside spec files under `spec/system/`, except for helper or shared files.
      #
      # Example:
      #
      #   # bad
      #   # spec/system/user_login_spec.rb
      #   allow(User).to receive(:find).and_return(user)
      #
      #   # good
      #   # spec/support/system_helpers.rb
      #   allow(User).to receive(:find).and_return(user)
      #
      class DisallowStubbingInSystemSpecs < RuboCop::Cop::Base
        extend ::RuboCop::Cop::AutoCorrector

        MSG = "Do not use stubbing/mocking in system tests.".freeze

        def on_send(node)
          return unless in_system_spec_file?
          return if in_helper_file?
          return unless stubbing_or_mocking?(node)

          add_offense(node.loc.selector, message: MSG, severity: :refactor)
        end

        private

        def in_system_spec_file?
          processed_source.file_path.match?(%r{spec/system/})
        end

        def in_helper_file?
          processed_source.file_path.match?(%r{spec/(support|shared)/}) ||
            processed_source.file_path.end_with?("_helper.rb")
        end

        def stubbing_or_mocking?(node)
          return true if node.method?(:allow)
          return true if node.method?(:stub)
          return true if node.method?(:stub_const)
          return true if node.method?(:receive)
          return true if node.method?(:receive_message_chain)

          # catch expect(...).to have_received(...)
          node.method?(:expect) && node.each_descendant(:send).any? { it.method?(:have_received) }
        end
      end
    end
  end
end
