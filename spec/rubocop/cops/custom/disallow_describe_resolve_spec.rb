require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/disallow_describe_resolve"

RSpec.describe RuboCop::Cops::Custom::DisallowDescribeResolve do
  let(:config) { RuboCop::Config.new("Custom/DisallowDescribeResolve" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for describe '#resolve' in a policy spec" do
    expect_offense(<<~RUBY, "spec/policies/admin/lot_policy_spec.rb")
      describe "#resolve" do
      ^^^^^^^^^^^^^^^^^^^ Do not use describe "#resolve" blocks.
      end
    RUBY
  end

  it "does not register an offense for other describe strings in a policy spec" do
    expect_no_offenses(<<~RUBY, "spec/policies/admin/lot_policy_spec.rb")
      describe "#resolve_scope" do
      end
    RUBY
  end

  it "does not register an offense for describe '#resolve' outside policy specs" do
    expect_no_offenses(<<~RUBY, "spec/services/addresses/resolver_service_spec.rb")
      describe "#resolve" do
      end
    RUBY
  end
end
