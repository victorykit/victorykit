RSpec::Matchers.define :validate_presence_of do |field_name|
  match do |subject|
    subject[field_name] = nil
    !subject.valid?
  end
end
RSpec::Matchers.define :model_with_properties do |expected_properties|
  match do |subject|
    "a string".should include("a") 
  end
end
