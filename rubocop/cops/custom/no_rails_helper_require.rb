module RuboCop
  module Cops
    module Custom
      class NoRailsHelperRequire < ::RuboCop::Cop::Base
        MSG = 'Do not require "rails_helper" in spec files. Use shared test setup without adding rails_helper requires.'.freeze

        def_node_matcher :rails_helper_require?, <<~PATTERN
          (send nil? :require (str "rails_helper"))
        PATTERN

        def on_send(node)
          return unless rails_helper_require?(node)

          add_offense(node)
        end
      end
    end
  end
end
