require 'guard/compat/test/helper'
require 'guard/coffeescript'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run focus: (ENV['CI'] != 'true')
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  # config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed

  config.before(:each) do
    @project_path    = Pathname.new(File.expand_path('../../', __FILE__))

    allow(Guard::UI).to receive(:info)
    allow(Guard::UI).to receive(:debug)
    allow(Guard::UI).to receive(:error)
    allow(Guard::UI).to receive(:warning)
    allow(Guard::UI).to receive(:color_enabled?).and_return(true)
  end
end
