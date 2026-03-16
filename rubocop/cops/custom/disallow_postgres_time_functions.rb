module RuboCop
  module Cops
    module Custom
      # Prevent usage of PostgreSQL time functions inside SQL strings.
      #
      # These functions (e.g. NOW(), CURRENT_TIMESTAMP) tie logic to database time,
      # which can cause subtle timezone or replication issues.
      # Prefer passing Time.current from Ruby instead.
      #
      # Example:
      #
      #   # bad
      #   Auction.where("start_time > NOW()")
      #
      #   # good
      #   Auction.where("start_time > ?", Time.current)
      #
      class DisallowPostgresTimeFunctions < ::RuboCop::Cop::Base
        MSG = "Avoid PostgreSQL time functions (e.g. NOW(), CURRENT_TIMESTAMP). Use Time.current in Ruby instead.".freeze

        # Policy: disallow PostgreSQL current-time/current-date sources in SQL
        # fragments to keep time semantics in Ruby. This intentionally includes
        # both transaction/statement/wall-clock functions and SQL keyword forms.
        TIME_FUNCTION_REGEX = /
          (?<!:)\b(?:
            NOW\s*\(\s*\) |
            TIMEOFDAY\s*\(\s*\) |
            (?:CURRENT_TIMESTAMP|CURRENT_TIME|LOCALTIME|LOCALTIMESTAMP)(?:\s*\(\s*\d+\s*\))?(?!\s*\(\s*\)) |
            (?:CURRENT_DATE|CLOCK_TIMESTAMP|STATEMENT_TIMESTAMP|TRANSACTION_TIMESTAMP)(?:\s*\(\s*\))?
          )(?=\W|$)
        /xi

        def on_str(node)
          file_path = processed_source.buffer.name
          return if file_path.end_with?("disallow_postgres_time_functions.rb")

          add_offense(node, message: MSG) if node.value.match?(TIME_FUNCTION_REGEX)
        end
      end
    end
  end
end
