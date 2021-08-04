class StimulusReflexTesting::Session
  def initialize
    @store = {}
  end

  def [](key)
    @store[key]
  end

  def []=(key, value)
    @store[key] = value
  end

  private

  def load!
    true
  end
end
