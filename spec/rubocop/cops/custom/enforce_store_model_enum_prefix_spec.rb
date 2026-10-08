require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/enforce_store_model_enum_prefix"

RSpec.describe RuboCop::Cops::Custom::EnforceStoreModelEnumPrefix do
  let(:config) { RuboCop::Config.new("Custom/EnforceStoreModelEnumPrefix" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for a StoreModel enum without a prefix" do
    expect_offense(<<~RUBY)
      enum :type, in: Auction.auction_types
      ^^^^ Declare StoreModel enum with `_prefix: true`.
    RUBY
  end

  it "registers an offense for a StoreModel enum with a custom prefix" do
    expect_offense(<<~RUBY)
      enum :type, in: %i[timed webcast], _prefix: :auction
      ^^^^ Declare StoreModel enum with `_prefix: true`.
    RUBY
  end

  it "registers an offense for a multi-line StoreModel enum without a prefix" do
    expect_offense(<<~RUBY)
      enum(
      ^^^^ Declare StoreModel enum with `_prefix: true`.
        :type,
        in: Auction.auction_types,
        default: :timed
      )
    RUBY
  end

  it "does not register an offense for a StoreModel enum with _prefix: true" do
    expect_no_offenses(<<~RUBY)
      enum :type, in: Auction.auction_types, _prefix: true
    RUBY
  end

  it "does not register an offense for a native_enum, which passes prefix: true itself" do
    expect_no_offenses(<<~RUBY)
      native_enum :sex, %i[M F]
    RUBY
  end

  it "does not register an offense for an ActiveRecord enum, which Custom/DisallowDefaultEnum covers" do
    expect_no_offenses(<<~RUBY)
      def native_enum(name, values, validate: true, prefix: true, **options)
        enum(name, values.index_with(&:to_s), validate: validate, prefix: prefix, **options)
      end
    RUBY
  end

  it "does not register an offense for migration enum columns" do
    expect_no_offenses(<<~RUBY)
      t.enum :lot_type, null: false, enum_type: "lots_type"
    RUBY
  end
end
