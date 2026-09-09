require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/disallow_describe_perform"

RSpec.describe RuboCop::Cops::Custom::DisallowDescribePerform do
  let(:config) { RuboCop::Config.new("Custom/DisallowDescribePerform" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for describe '#perform'" do
    expect_offense(<<~RUBY)
      describe "#perform" do
      ^^^^^^^^^^^^^^^^^^^ Do not use describe "#perform" blocks.
      end
    RUBY
  end

  it "does not register an offense for other describe strings" do
    expect_no_offenses(<<~RUBY)
      describe "#perform_async" do
      end
    RUBY
  end
end
