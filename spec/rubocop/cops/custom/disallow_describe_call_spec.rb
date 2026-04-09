require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/disallow_describe_call"

RSpec.describe RuboCop::Cops::Custom::DisallowDescribeCall do
  let(:config) { RuboCop::Config.new("Custom/DisallowDescribeCall" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for describe '#call'" do
    expect_offense(<<~RUBY)
      describe "#call" do
      ^^^^^^^^^^^^^^^^ Do not use describe "#call" blocks.
      end
    RUBY
  end

  it "does not register an offense for other describe strings" do
    expect_no_offenses(<<~RUBY)
      describe "#perform" do
      end
    RUBY
  end
end
