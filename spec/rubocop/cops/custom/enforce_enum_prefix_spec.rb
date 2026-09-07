require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/enforce_enum_prefix"

RSpec.describe RuboCop::Cops::Custom::EnforceEnumPrefix do
  let(:config) { RuboCop::Config.new("Custom/EnforceEnumPrefix" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for an enum without a prefix" do
    expect_offense(<<~RUBY)
      enum :status, { placed: 0, cancelled: 1 }, validate: true
      ^^^^ Declare enum with `prefix: true`.
    RUBY
  end

  it "registers an offense for a native_enum without options" do
    expect_offense(<<~RUBY)
      native_enum :sex, %i[M F]
      ^^^^^^^^^^^ Declare enum with `prefix: true`.
    RUBY
  end

  it "registers an offense for a custom prefix" do
    expect_offense(<<~RUBY)
      native_enum :kind, %i[a b], prefix: :thing
      ^^^^^^^^^^^ Declare enum with `prefix: true`.
    RUBY
  end

  it "registers an offense for a suffix" do
    expect_offense(<<~RUBY)
      enum :status, { placed: 0 }, suffix: true
      ^^^^ Declare enum with `prefix: true`.
    RUBY
  end

  it "registers an offense for a multi-line enum without a prefix" do
    expect_offense(<<~RUBY)
      enum(
      ^^^^ Declare enum with `prefix: true`.
        :status,
        { placed: 0, cancelled: 1 },
        validate: true
      )
    RUBY
  end

  it "does not register an offense for an enum with prefix: true" do
    expect_no_offenses(<<~RUBY)
      enum :status, { placed: 0, cancelled: 1 }, prefix: true, validate: true
    RUBY
  end

  it "does not register an offense for a native_enum with prefix: true" do
    expect_no_offenses(<<~RUBY)
      native_enum :sex, %i[M F], prefix: true
    RUBY
  end

  it "does not register an offense for a StoreModel enum with _prefix: true" do
    expect_no_offenses(<<~RUBY)
      enum :type, in: Auction.auction_types, _prefix: true
    RUBY
  end

  it "registers an offense for a StoreModel enum with a custom _prefix" do
    expect_offense(<<~RUBY)
      enum :type, in: Auction.auction_types, _prefix: :thing
      ^^^^ Declare enum with `prefix: true`.
    RUBY
  end

  it "does not register an offense for migration enum columns" do
    expect_no_offenses(<<~RUBY)
      t.enum :lot_type, null: false, enum_type: "lots_type"
    RUBY
  end
end
