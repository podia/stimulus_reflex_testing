require 'test_helper'

class BuildReflexTest < MiniTest::Test
  class TestReflex < StimulusReflex::Reflex
  end

  class TestClass
    include StimulusReflex::TestCase::Behavior
    def self.reflex_class
      TestReflex
    end
  end

  def test_it_supplies_the_correct_arguments_to_a_reflex
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [StimulusReflex::TestCase::TestChannel, Hash])

    TestReflex.stub(:new, mock) do
      TestClass.new.build_reflex(method_name: :create, url: 'http://localhost/url')
    end

    mock.verify
  end
end
