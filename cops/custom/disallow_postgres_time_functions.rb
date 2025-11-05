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
    class DisallowPostgresTimeFunctions < Base
      MSG = "Avoid PostgreSQL time functions (e.g. NOW(), CURRENT_TIMESTAMP). Use Time.current in Ruby instead.".freeze

      TIME_FUNCTION_REGEX = /
        \b(
          NOW |
          CURRENT_TIMESTAMP |
          CURRENT_DATE |
          CURRENT_TIME |
          LOCALTIME |
          LOCALTIMESTAMP |
          CLOCK_TIMESTAMP |
          STATEMENT_TIMESTAMP |
          TRANSACTION_TIMESTAMP |
          TIMEOFDAY
        )\s*\(?\s*\)?\b
      /x

      def on_str(node)
        file_path = processed_source.buffer.name
        return if file_path.end_with?("disallow_postgres_time_functions.rb")

        add_offense(node, message: MSG) if node.value.match?(TIME_FUNCTION_REGEX)
      end
    end
  end
end
