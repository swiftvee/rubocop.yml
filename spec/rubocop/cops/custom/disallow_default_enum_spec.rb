require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/disallow_default_enum"

RSpec.describe RuboCop::Cops::Custom::DisallowDefaultEnum do
  let(:config) { RuboCop::Config.new("Custom/DisallowDefaultEnum" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for the default enum" do
    expect_offense(<<~RUBY)
      enum :status, { placed: 0, cancelled: 1 }, validate: true
      ^^^^ Use native_enum instead of the default enum.
    RUBY
  end

  it "registers an offense for the parenthesised default enum" do
    expect_offense(<<~RUBY)
      enum(:status, { placed: 0, cancelled: 1 }, validate: true)
      ^^^^ Use native_enum instead of the default enum.
    RUBY
  end

  it "does not register an offense for native_enum" do
    expect_no_offenses(<<~RUBY)
      native_enum :status, %i[placed cancelled], validate: true
    RUBY
  end

  it "does not register an offense for migration enum columns" do
    expect_no_offenses(<<~RUBY)
      t.enum :lot_type, null: false, enum_type: "lots_type"
    RUBY
  end
end
