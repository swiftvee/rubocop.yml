require_relative "../../../spec_helper"
require_relative "../../../../rubocop/cops/custom/enforce_service_class_suffix"

RSpec.describe RuboCop::Cops::Custom::EnforceServiceClassSuffix do
  let(:config) { RuboCop::Config.new("Custom/EnforceServiceClassSuffix" => {"Enabled" => true}) }
  let(:cop) { described_class.new(config) }

  it "registers an offense for a service class without the suffix" do
    expect_offense(<<~RUBY, "app/services/lots/activater.rb")
      module Lots
        class Activater < BaseService
              ^^^^^^^^^ Name a class in app/services with a Service suffix.
        end
      end
    RUBY
  end

  it "registers an offense for a compact namespaced class without the suffix" do
    expect_offense(<<~RUBY, "app/services/lots/activater.rb")
      class Lots::Activater < BaseService
            ^^^^^^^^^^^^^^^ Name a class in app/services with a Service suffix.
      end
    RUBY
  end

  it "registers an offense for a nested class that is not an exception" do
    expect_offense(<<~RUBY, "app/services/lots/activater_service.rb")
      module Lots
        class ActivaterService < BaseService
          class Result
                ^^^^^^ Name a class in app/services with a Service suffix.
          end
        end
      end
    RUBY
  end

  it "does not register an offense for a class with the suffix" do
    expect_no_offenses(<<~RUBY, "app/services/lots/activater_service.rb")
      module Lots
        class ActivaterService < BaseService
        end
      end
    RUBY
  end

  it "does not register an offense for exception classes" do
    expect_no_offenses(<<~RUBY, "app/services/auctions/payments/paystack_processor_service.rb")
      module Auctions
        class PaystackProcessorService < ApplicationService
          class MismatchedAmountError < StandardError; end
          class DuplicateCharge < PaymentError; end
        end
      end
    RUBY
  end

  it "does not register an offense for a module" do
    expect_no_offenses(<<~RUBY, "app/services/turbo_streamer.rb")
      module TurboStreamer
      end
    RUBY
  end

  it "does not register an offense for a singleton class" do
    expect_no_offenses(<<~RUBY, "app/services/application_service.rb")
      class ApplicationService
        class << self
          def call(...)
          end
        end
      end
    RUBY
  end

  it "does not inspect classes outside app/services" do
    expect_no_offenses(<<~RUBY, "app/models/lot.rb")
      class Lot < ApplicationRecord
      end
    RUBY
  end
end
