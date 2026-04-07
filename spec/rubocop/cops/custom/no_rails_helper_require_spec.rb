require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/no_rails_helper_require"

RSpec.describe RuboCop::Cops::Custom::NoRailsHelperRequire do
  let(:config) { RuboCop::Config.new("Custom/NoRailsHelperRequire" => { "Enabled" => true }) }
  let(:cop) { described_class.new(config) }

  context "when requiring rails_helper" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        require "rails_helper"
        ^^^^^^^^^^^^^^^^^^^^^^ #{described_class::MSG}
      RUBY
    end
  end

  context "when requiring relative rails_helper" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        require_relative "rails_helper"
      RUBY
    end
  end

  context "when not requiring rails_helper" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        require "spec_helper"
      RUBY
    end
  end
end
