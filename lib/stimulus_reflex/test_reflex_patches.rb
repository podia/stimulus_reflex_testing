module StimulusReflex::TestReflexPatches
  def get(instance_variable)
    instance_variable_get("@#{instance_variable}")
  end

  def run(method_name, *args)
    process(method_name, *args)
  end
end

StimulusReflex::Reflex.include(StimulusReflex::TestReflexPatches)
