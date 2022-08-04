require "test_helper"

class StimulusReflexTestingTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::StimulusReflexTesting::VERSION
  end

  def test_includes_version_number_for_sr_350pre9_and_newer
    mock = MiniTest::Mock.new
    opts = { channel: 'TestChannel', element: 'TestElement', url: 'https://test.xyz', method_name: 'test' }

    mock.expect(:call, true) do |channel, element:, url:, method_name:, params:, client_attributes:|
      assert_equal('3.5.0pre9', client_attributes[:version])
    end

    TestReflexClass.stub(:new, mock) do
      TestClass.new.build_reflex(opts, '3.5.0pre9')
    end
    mock.verify
  end

  def test_does_not_include_version_number_for_sr_350pre8_and_older
    mock = MiniTest::Mock.new
    opts = { channel: 'TestChannel', element: 'TestElement', url: 'https://test.xyz', method_name: 'test' }

    mock.expect(:call, true) do |channel, element:, url:, method_name:, params:, client_attributes:|
      assert_nil(client_attributes[:version])
    end

    TestReflexClass.stub(:new, mock) do
      TestClass.new.build_reflex(opts, '3.5.0pre8')
    end
  end
end

class TestClass
  include StimulusReflex::TestCase::Behavior

  def self.reflex_class
    TestReflexClass
  end
end

class TestReflexClass
  def initialize(channel, url:, element:, method_name:, params:, client_attributes:); true; end
end
