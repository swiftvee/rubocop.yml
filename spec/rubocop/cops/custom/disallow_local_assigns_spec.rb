require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/disallow_local_assigns"

RSpec.describe RuboCop::Cops::Custom::DisallowLocalAssigns do
  let(:config) { RuboCop::Config.new("Custom/DisallowLocalAssigns" => { "Enabled" => true }) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for local_assigns usage" do
    expect_offense(<<~RUBY)
      local_assigns
      ^^^^^^^^^^^^^ Do not use local_assigns.
    RUBY
  end

  it "registers an offense for indexed local_assigns usage" do
    expect_offense(<<~RUBY)
      local_assigns[:title]
      ^^^^^^^^^^^^^ Do not use local_assigns.
    RUBY
  end

  it "does not register an offense for other local variables" do
    expect_no_offenses(<<~RUBY)
      locals = { title: "Hello" }
      locals[:title]
    RUBY
  end
end
