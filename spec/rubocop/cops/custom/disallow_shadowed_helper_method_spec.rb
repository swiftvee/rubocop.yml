require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/disallow_shadowed_helper_method"

RSpec.describe RuboCop::Cops::Custom::DisallowShadowedHelperMethod do
  let(:config) { RuboCop::Config.new("Custom/DisallowShadowedHelperMethod" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for a subject named after the described method" do
    expect_offense(<<~RUBY, "spec/helpers/application_helper_spec.rb")
      RSpec.describe ApplicationHelper do
        describe "#og_request_url" do
          subject(:og_request_url) { helper.og_request_url }
                  ^^^^^^^^^^^^^^^ Do not name a let or subject after the method under test; it shadows the helper.
        end
      end
    RUBY
  end

  it "registers an offense for a let named after a method described elsewhere in the file" do
    expect_offense(<<~RUBY, "spec/helpers/asset_helper_spec.rb")
      RSpec.describe AssetHelper do
        describe "#image_blob_url" do
        end

        describe "#video_poster_url" do
          let(:image_blob_url) { "https://example.test/1.png" }
              ^^^^^^^^^^^^^^^ Do not name a let or subject after the method under test; it shadows the helper.
        end
      end
    RUBY
  end

  it "registers an offense for let!" do
    expect_offense(<<~RUBY, "spec/helpers/auctions_helper_spec.rb")
      RSpec.describe AuctionsHelper do
        describe "#bid_type" do
          let!(:bid_type) { "online" }
               ^^^^^^^^^ Do not name a let or subject after the method under test; it shadows the helper.
        end
      end
    RUBY
  end

  it "registers an offense for a method described with a context" do
    expect_offense(<<~RUBY, "spec/helpers/auctions_helper_spec.rb")
      RSpec.describe AuctionsHelper do
        context "#bid_type" do
          subject(:bid_type) { helper.bid_type }
                  ^^^^^^^^^ Do not name a let or subject after the method under test; it shadows the helper.
        end
      end
    RUBY
  end

  it "does not register an offense for an anonymous subject" do
    expect_no_offenses(<<~RUBY, "spec/helpers/asset_helper_spec.rb")
      RSpec.describe AssetHelper do
        describe "#image_blob_url" do
          subject { helper.image_blob_url(blob, width: width) }
        end
      end
    RUBY
  end

  it "does not register an offense for an unrelated name" do
    expect_no_offenses(<<~RUBY, "spec/helpers/asset_helper_spec.rb")
      RSpec.describe AssetHelper do
        describe "#image_blob_url" do
          subject(:url) { helper.image_blob_url(blob, width: width) }

          let(:width) { 300 }
        end
      end
    RUBY
  end

  it "does not register an offense for a described class method" do
    expect_no_offenses(<<~RUBY, "spec/helpers/asset_helper_spec.rb")
      RSpec.describe AssetHelper do
        describe ".build" do
          subject(:build) { described_class.build }
        end
      end
    RUBY
  end

  it "does not inspect specs outside spec/helpers" do
    expect_no_offenses(<<~RUBY, "spec/presenters/lots/card_presenter_spec.rb")
      RSpec.describe Lots::CardPresenter do
        describe "#render_bid_button?" do
          subject(:render_bid_button?) { presenter.render_bid_button? }
        end
      end
    RUBY
  end
end
