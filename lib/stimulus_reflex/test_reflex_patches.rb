module StimulusReflex::TestReflexPatches
  def get(instance_variable)
    instance_variable_get("@#{instance_variable}")
  end

  def run(reflex_method = nil, *args)
    reflex_to_run = reflex_method || method_name

    if reflex_to_run
      process(reflex_to_run, *args)
    else
      raise "You must provide the method you want to run for #{self.class.name}"
    end
  end

  # def cable_ready
  #   @cable_ready ||= FableReady.new
  # end

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
