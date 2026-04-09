require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/enforce_dependent_nil_for_lambda_relations"

RSpec.describe RuboCop::Cops::Custom::EnforceDependentNilForLambdaRelations do
  let(:config) { RuboCop::Config.new("Custom/EnforceDependentNilForLambdaRelations" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for has_many with a lambda and no dependent option" do
    expect_offense(<<~RUBY)
      has_many :bids, -> { active }
      ^^^^^^^^ Associations with a lambda scope must set dependent: nil.
    RUBY
  end

  it "registers an offense for has_one with a lambda and non-nil dependent option" do
    expect_offense(<<~RUBY)
      has_one :invoice, -> { recent }, dependent: :destroy
      ^^^^^^^ Associations with a lambda scope must set dependent: nil.
    RUBY
  end

  it "does not register an offense for has_many with a lambda and dependent: nil" do
    expect_no_offenses(<<~RUBY)
      has_many :bids, -> { active }, dependent: nil
    RUBY
  end

  it "does not register an offense for has_many without a lambda" do
    expect_no_offenses(<<~RUBY)
      has_many :bids, class_name: "Bid"
    RUBY
  end

  it "does not register an offense when dependent: nil appears with other options" do
    expect_no_offenses(<<~RUBY)
      has_one :invoice, -> { recent }, class_name: "Invoice", dependent: nil
    RUBY
  end
end
