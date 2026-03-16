require "rubocop"
require_relative "../../../../rubocop/cops/custom/disallow_postgres_time_functions"

RSpec.describe RuboCop::Cops::Custom::DisallowPostgresTimeFunctions do
  subject(:time_function_regex) { described_class::TIME_FUNCTION_REGEX }

  describe "TIME_FUNCTION_REGEX" do
    it "matches all configured PostgreSQL current time/date function forms" do
      matching_sql_fragments = [
        "NOW()",
        "CURRENT_TIMESTAMP",
        "CURRENT_TIMESTAMP(3)",
        "CURRENT_DATE",
        "CURRENT_DATE()",
        "CURRENT_TIME",
        "CURRENT_TIME(2)",
        "LOCALTIME",
        "LOCALTIME(0)",
        "LOCALTIMESTAMP",
        "LOCALTIMESTAMP(6)",
        "CLOCK_TIMESTAMP",
        "CLOCK_TIMESTAMP()",
        "STATEMENT_TIMESTAMP",
        "STATEMENT_TIMESTAMP()",
        "TRANSACTION_TIMESTAMP",
        "TRANSACTION_TIMESTAMP()",
        "TIMEOFDAY()"
      ]

      matching_sql_fragments.each do |fragment|
        expect(fragment.match?(time_function_regex)).to be(true), "expected '#{fragment}' to match"
      end
    end

    it "does not match prose or bind placeholders" do
      non_matching_fragments = [
        "is now live",
        ":current_time",
        "snow report",
        "current_timestampish",
        "NOW"
      ]

      non_matching_fragments.each do |fragment|
        expect(fragment.match?(time_function_regex)).to be(false), "expected '#{fragment}' not to match"
      end
    end
  end
end
