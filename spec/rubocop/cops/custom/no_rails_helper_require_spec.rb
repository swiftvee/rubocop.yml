require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/no_rails_helper_require"

RSpec.describe RuboCop::Cops::Custom::NoRailsHelperRequire do
  subject(:offenses) { investigate(source).offenses }

  let(:cop) { described_class.new }

  def investigate(source)
    processed_source = RuboCop::ProcessedSource.new(source, RUBY_VERSION.to_f)
    commissioner = RuboCop::Cop::Commissioner.new([cop], [], raise_error: true)

    commissioner.investigate(processed_source)
  end

  context 'when requiring "rails_helper"' do
    let(:source) { 'require "rails_helper"' }

    it "registers one offense" do
      expect(offenses.size).to eq(1)
    end

    it "uses the configured message" do
      expect(offenses.first.message).to include(described_class::MSG)
    end
  end

  context "when not requiring rails_helper" do
    let(:source) { 'require "spec_helper"' }

    it { is_expected.to be_empty }
  end
end
