require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/enforce_application_record_transaction"

RSpec.describe RuboCop::Cops::Custom::EnforceApplicationRecordTransaction do
  let(:config) { RuboCop::Config.new("Custom/EnforceApplicationRecordTransaction" => { "Enabled" => true }) }
  let(:cop) { described_class.new(config) }

  it "does not register an offense for ApplicationRecord.transaction" do
    expect_no_offenses(<<~RUBY)
      ApplicationRecord.transaction { do_stuff }
    RUBY
  end

  it "registers an offense for ActiveRecord::Base.transaction" do
    expect_offense(<<~RUBY)
      ActiveRecord::Base.transaction { do_stuff }
                         ^^^^^^^^^^^ Use ApplicationRecord.transaction for transaction blocks.
    RUBY
  end

  it "registers an offense for instance transaction calls" do
    expect_offense(<<~RUBY)
      auction.transaction { do_stuff }
              ^^^^^^^^^^^ Use ApplicationRecord.transaction for transaction blocks.
    RUBY
  end

  it "registers an offense for implicit receiver transaction calls" do
    expect_offense(<<~RUBY)
      transaction { do_stuff }
      ^^^^^^^^^^^ Use ApplicationRecord.transaction for transaction blocks.
    RUBY
  end

  it "does not register offenses for non-block transaction method usage" do
    expect_no_offenses(<<~RUBY)
      transaction.id
    RUBY
  end
end