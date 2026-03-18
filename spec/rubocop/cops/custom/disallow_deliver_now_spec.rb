require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/disallow_deliver_now"

RSpec.describe RuboCop::Cops::Custom::DisallowDeliverNow do
  let(:config) { RuboCop::Config.new("Custom/DisallowDeliverNow" => { "Enabled" => true }) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for deliver_now" do
    expect_offense(<<~RUBY)
      UserMailer.welcome(user).deliver_now
                               ^^^^^^^^^^^ Use deliver_later instead of deliver_now.
    RUBY

    expect_correction(<<~RUBY)
      UserMailer.welcome(user).deliver_later
    RUBY
  end

  it "registers an offense for safe navigation calls" do
    expect_offense(<<~RUBY)
      mailer&.deliver_now
              ^^^^^^^^^^^ Use deliver_later instead of deliver_now.
    RUBY

    expect_correction(<<~RUBY)
      mailer&.deliver_later
    RUBY
  end

  it "does not register offenses for deliver_later" do
    expect_no_offenses(<<~RUBY)
      UserMailer.welcome(user).deliver_later
    RUBY
  end

  it "does not inspect spec files" do
    file = "spec/mailers/application_mailer_spec.rb"

    expect_no_offenses("some_mail.deliver_now", file)
  end
end
