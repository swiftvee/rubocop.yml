require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/disallow_be_truthy_be_falsey"

RSpec.describe RuboCop::Cops::Custom::DisallowBeTruthyBeFalsey do
  let(:config) { RuboCop::Config.new("Custom/DisallowBeTruthyBeFalsey" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for be_truthy" do
    expect_offense(<<~RUBY)
      expect(result).to be_truthy
                        ^^^^^^^^^ Do not use be_truthy; assert the exact value instead (e.g. be(true) or be(false)).
    RUBY
  end

  it "registers an offense for be_falsey" do
    expect_offense(<<~RUBY)
      expect(result).to be_falsey
                        ^^^^^^^^^ Do not use be_falsey; assert the exact value instead (e.g. be(true) or be(false)).
    RUBY
  end

  it "does not register an offense for be(true) or be(false)" do
    expect_no_offenses(<<~RUBY)
      expect(result).to be(true)
      expect(result).to be(false)
    RUBY
  end

  it "does not register an offense for unrelated method calls with a receiver" do
    expect_no_offenses(<<~RUBY)
      thing.be_truthy
    RUBY
  end
end
