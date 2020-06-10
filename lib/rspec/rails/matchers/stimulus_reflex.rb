require "rspec/matchers"

RSpec::Matchers.define :have_set do |instance_variable, expected_value|
  match do |actual|
    actual.get(instance_variable) == expected_value
  end

  description do |actual|
    "set #{instance_variable} to #{expected_value}, got #{actual.get(instance_variable)}"
  end
end
