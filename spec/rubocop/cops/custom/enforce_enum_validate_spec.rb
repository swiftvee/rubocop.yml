require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/enforce_enum_validate"

RSpec.describe RuboCop::Cops::Custom::EnforceEnumValidate do
  let(:config) { RuboCop::Config.new("Custom/EnforceEnumValidate" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for an enum without validate" do
    expect_offense(<<~RUBY)
      enum :status, { placed: 0, cancelled: 1 }, prefix: true
      ^^^^ Declare enum with `validate: true` or `validate: { ... }`.
    RUBY
  end

  it "registers an offense for a native_enum without options" do
    expect_offense(<<~RUBY)
      native_enum :sex, %i[M F]
      ^^^^^^^^^^^ Declare enum with `validate: true` or `validate: { ... }`.
    RUBY
  end

  it "registers an offense for validate: false" do
    expect_offense(<<~RUBY)
      native_enum :sex, %i[M F], prefix: true, validate: false
      ^^^^^^^^^^^ Declare enum with `validate: true` or `validate: { ... }`.
    RUBY
  end

  it "registers an offense for a multi-line enum without validate" do
    expect_offense(<<~RUBY)
      enum(
      ^^^^ Declare enum with `validate: true` or `validate: { ... }`.
        :status,
        { placed: 0, cancelled: 1 },
        prefix: true
      )
    RUBY
  end

  it "does not register an offense for an enum with validate: true" do
    expect_no_offenses(<<~RUBY)
      enum :status, { placed: 0, cancelled: 1 }, prefix: true, validate: true
    RUBY
  end

  it "does not register an offense for a native_enum with validate options" do
    expect_no_offenses(<<~RUBY)
      native_enum :sex, %i[M F], prefix: true, validate: { allow_nil: true }
    RUBY
  end

  it "does not register an offense for a StoreModel enum" do
    expect_no_offenses(<<~RUBY)
      enum :type, in: Auction.auction_types, _prefix: true
    RUBY
  end

  it "does not register an offense for migration enum columns" do
    expect_no_offenses(<<~RUBY)
      t.enum :lot_type, null: false, enum_type: "lots_type"
    RUBY
  end
end
