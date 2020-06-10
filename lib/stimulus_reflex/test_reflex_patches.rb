module StimulusReflex::TestReflexPatches
  class ActionDispatch::Request
    def session
      StimulusReflex::Reflex::Session.new
    end
  end

  class Session
    def load!
      true
    end
  end

  def get(instance_variable)
    instance_variable_get("@#{instance_variable}")
  end

  def run(method_name, *args)
    process(method_name, *args)
  end
end

StimulusReflex::Reflex.include(StimulusReflex::TestReflexPatches)
