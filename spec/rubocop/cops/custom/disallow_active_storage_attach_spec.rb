require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/disallow_active_storage_attach"

RSpec.describe RuboCop::Cops::Custom::DisallowActiveStorageAttach do
  let(:config) { RuboCop::Config.new("Custom/DisallowActiveStorageAttach" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for attach on an attachment relation" do
    expect_offense(<<~RUBY)
      lot.images.attach(blob)
                 ^^^^^^ Assign the attachment as an attribute instead of calling attach.
    RUBY
  end

  it "registers an offense for attach with an attachable hash" do
    expect_offense(<<~RUBY)
      animal.genetic_data.attach(io: io, filename: "gene.png", content_type: "image/png")
                          ^^^^^^ Assign the attachment as an attribute instead of calling attach.
    RUBY
  end

  it "registers an offense for safe navigation calls" do
    expect_offense(<<~RUBY)
      lot.genetic_data&.attach(blob)
                        ^^^^^^ Assign the attachment as an attribute instead of calling attach.
    RUBY
  end

  it "registers an offense for a method reference to attach" do
    expect_offense(<<~RUBY)
      blob.tap(&auction.facebook_images.method(:attach))
                                               ^^^^^^^ Assign the attachment as an attribute instead of calling attach.
    RUBY
  end

  it "does not register an offense for assigning the attachment" do
    expect_no_offenses(<<~RUBY)
      lot.update!(images: [blob])
    RUBY
  end

  it "does not register an offense for a receiverless attach" do
    expect_no_offenses(<<~RUBY)
      def attach
        attach
      end
    RUBY
  end

  it "does not register an offense for other attachment predicates" do
    expect_no_offenses(<<~RUBY)
      lot.genetic_data.attached?
    RUBY
  end

  it "does not register an offense for a method reference to another method" do
    expect_no_offenses(<<~RUBY)
      blob.tap(&auction.facebook_images.method(:purge))
    RUBY
  end
end
