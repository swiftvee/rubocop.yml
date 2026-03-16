require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/disallow_postgres_time_functions"

RSpec.describe RuboCop::Cops::Custom::DisallowPostgresTimeFunctions do
  subject(:time_function_regex) { described_class::TIME_FUNCTION_REGEX }

  let(:config) { RuboCop::Config.new("Custom/DisallowPostgresTimeFunctions" => { "Enabled" => true }) }
  let(:cop) { described_class.new(config) }

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

    it "does not match precision functions with empty parentheses" do
      non_matching_fragments = [
        "CURRENT_TIMESTAMP()",
        "CURRENT_TIME()",
        "LOCALTIME()",
        "LOCALTIMESTAMP()"
      ]

      non_matching_fragments.each do |fragment|
        expect(fragment.match?(time_function_regex)).to be(false), "expected '#{fragment}' not to match"
      end
    end
  end

  describe "cop behavior" do
    it "registers an offense for NOW() in SQL strings" do
      offenses = inspect_source("Auction.where(\"start_time > NOW()\")")

      expect(offenses.length).to eq(1)
      expect(offenses.first.message).to eq(described_class::MSG)
    end

    it "registers an offense for CURRENT_TIMESTAMP precision form" do
      offenses = inspect_source("User.where(\"updated_at >= CURRENT_TIMESTAMP(3)\")")

      expect(offenses.length).to eq(1)
      expect(offenses.first.message).to eq(described_class::MSG)
    end

    it "does not register offenses for prose strings" do
      expect_no_offenses(<<~RUBY)
        "Your auction is now live"
      RUBY
    end

    it "does not register offenses for bind placeholders" do
      expect_no_offenses(<<~RUBY)
        Auction.where("start_time < :current_time")
      RUBY
    end

    it "does not inspect itself" do
      file = "rubocop/cops/custom/disallow_postgres_time_functions.rb"
      expect_no_offenses("\"NOW()\"", file)
    end
  end
end
