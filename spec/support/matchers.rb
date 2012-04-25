RSpec::Matchers.define :validate_presence_of do |field_name|
  match do |subject|
    subject[field_name] = nil
    !subject.valid?
  end
end
