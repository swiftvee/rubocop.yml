require "rubocop"
require "rubocop/rspec/support"

require_relative "../rubocop/cops/custom/disallow_postgres_time_functions"

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense
end
