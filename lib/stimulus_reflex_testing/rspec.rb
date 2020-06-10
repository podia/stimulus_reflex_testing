require "rspec/rails/example/reflex_example_group"
require "rspec/rails/matchers/stimulus_reflex"

RSpec.configure do |config|
  if defined?(StimulusReflex)
    config.include Rails.application.routes.url_helpers, type: :reflex
    config.include RSpec::Rails::ReflexExampleGroup, type: :reflex

    config.before type: :reflex do
      allow_any_instance_of(ActionDispatch::Request).to(
        receive(:session).and_return(double(:session, load!: true))
      )
    end
  end
end
