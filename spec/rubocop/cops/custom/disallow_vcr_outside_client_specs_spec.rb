require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/disallow_vcr_outside_client_specs"

RSpec.describe RuboCop::Cops::Custom::DisallowVcrOutsideClientSpecs do
  let(:config) { RuboCop::Config.new("Custom/DisallowVcrOutsideClientSpecs" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for VCR.use_cassette" do
    expect_offense(<<~RUBY, "spec/models/widget_spec.rb")
      VCR.use_cassette("widget") { Widget.fetch }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Only use VCR cassettes in spec/clients.
    RUBY
  end

  it "registers an offense for VCR.insert_cassette" do
    expect_offense(<<~RUBY, "spec/models/widget_spec.rb")
      VCR.insert_cassette("widget")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Only use VCR cassettes in spec/clients.
    RUBY
  end

  it "registers an offense for the :vcr metadata symbol" do
    expect_offense(<<~RUBY, "spec/lib/s3/multipart_upload_spec.rb")
      RSpec.describe S3::MultipartUpload, :vcr do
                                          ^^^^ Only use VCR cassettes in spec/clients.
      end
    RUBY
  end

  it "registers an offense for the vcr: metadata pair" do
    expect_offense(<<~RUBY, "spec/models/widget_spec.rb")
      it "fetches", vcr: { record: :none } do
                    ^^^ Only use VCR cassettes in spec/clients.
      end
    RUBY
  end

  it "does not register an offense for VCR.configure" do
    expect_no_offenses(<<~RUBY, "spec/models/widget_spec.rb")
      VCR.configure do |config|
        config.hook_into :webmock
      end
    RUBY
  end

  it "does not register an offense in spec/clients" do
    expect_no_offenses(<<~RUBY, "spec/clients/widget_client_spec.rb")
      RSpec.describe WidgetClient, :vcr do
        it "fetches" do
          VCR.use_cassette("widget") { WidgetClient.fetch }
        end
      end
    RUBY
  end

  it "does not register an offense for unrelated constants or symbols" do
    expect_no_offenses(<<~RUBY, "spec/models/widget_spec.rb")
      Widget.find(:vcr_id)
      VCRecorder.use_cassette("widget")
    RUBY
  end
end
