module StimulusReflex::TestReflexPatches
  def get(instance_variable)
    instance_variable_get("@#{instance_variable}")
  end

  def run(method_name, *args)
    process(method_name, *args)
  end

  def cable_ready
    @cable_ready ||= FableReady.new
  end

  class FableReady
    def [](key)
      self
    end

    def method_missing(*)
      self
    end

    def respond_to_missing?(*)
      true
    end
  end
end

StimulusReflex::Reflex.include(StimulusReflex::TestReflexPatches)
