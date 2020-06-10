require "rspec/rails/example/reflex_example_group"
require "rspec/rails/matchers/stimulus_reflex"

RSpec.configure do |config|
  if defined?(StimulusReflex)
    config.include Rails.application.routes.url_helpers, type: :reflex
    config.include RSpec::Rails::ReflexExampleGroup, type: :reflex
  end
end
