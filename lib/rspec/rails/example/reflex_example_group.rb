if defined?(StimulusReflex)
  module RSpec
    module Rails
      module ReflexExampleGroup
        extend ActiveSupport::Concern
        include StimulusReflex::TestCase::Behavior

        module ClassMethods
          def reflex_class
            described_class
          end
        end
      end
    end
  end
end
