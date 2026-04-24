require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/disallow_private_methods_in_helpers"

RSpec.describe RuboCop::Cops::Custom::DisallowPrivateMethodsInHelpers do
  let(:config) { RuboCop::Config.new("Custom/DisallowPrivateMethodsInHelpers" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for private in helper files" do
    expect_offense(<<~RUBY, "app/helpers/application_helper.rb")
      module ApplicationHelper
        private
        ^^^^^^^ Do not define private helper methods in app/helpers. Keep helper methods public.

        def secret_text
          "hidden"
        end
      end
    RUBY
  end

  it "registers an offense for private with explicit method names in helper files" do
    expect_offense(<<~RUBY, "app/helpers/application_helper.rb")
      module ApplicationHelper
        private :secret_text
        ^^^^^^^ Do not define private helper methods in app/helpers. Keep helper methods public.
      end
    RUBY
  end

  it "does not register an offense in non-helper files" do
    expect_no_offenses(<<~RUBY, "app/models/user.rb")
      class User < ApplicationRecord
        private

        def token
          "abc"
        end
      end
    RUBY
  end

  it "does not register an offense for calls to private on another object" do
    expect_no_offenses(<<~RUBY, "app/helpers/application_helper.rb")
      logger.private
    RUBY
  end
end
