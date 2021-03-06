require "rspec/matchers"

RSpec::Matchers.define :have_set do |instance_variable, expected_value|
  match do |actual|
    actual.get(instance_variable) == expected_value
  end

  description do |actual|
    "set #{instance_variable} to #{expected_value}, got #{actual.get(instance_variable)}"
  end
end

RSpec::Matchers.define :broadcast do |**broadcasts|
  match do |block|
    fable_ready = StimulusReflex::TestReflexPatches::FableReady.new

    allow_any_instance_of(StimulusReflex::CableReadyChannels).to(
      receive(:[]).and_return(fable_ready)
    )

    broadcasts.each do |broadcast|
      if broadcast.is_a?(Array)
        if broadcast[1].present?
          expect(fable_ready).to receive(broadcast[0]).with(broadcast[1]).and_return(fable_ready)
        else
          expect(fable_ready).to receive(broadcast[0]).and_return(fable_ready)
        end
      else
        expect(fable_ready).to receive(broadcast).and_return(fable_ready)
      end
    end

    block.call

    RSpec::Mocks.verify
  end

  def supports_block_expectations?
    true
  end
end

RSpec::Matchers.define :morph do |selector|
  match do |morphs|
    if morphs.is_a?(StimulusReflex::NothingBroadcaster)
      return selector.to_s == "nothing"
    end

    morph = matching_morph(morphs, selector)

    if morph.present? && @with_chain_called
      @content == morph[1]
    else
      morph
    end
  end

  description do |morphs|
    morph = matching_morph(morphs, selector)

    if @with_chain_called
      if !morph
        "morph #{selector} but a morph for that selector was not run"
      else
        "morph #{selector} with #{@content} but the value was: #{morph[1]}"
      end
    else
      "morph #{selector} but a morph for that selector was not run"
    end
  end

  chain :with do |content|
    @with_chain_called = true
    @content = content
  end

  def supports_block_expectations?
    true
  end

  def matching_morph(morphs, selector)
    if morphs.respond_to?(:call)
      morphs.call.find { |morph| morph[0] == selector }
    else
      morphs.find { |morph| morph[0] == selector }
    end
  end

  diffable
end
