RSpec::Matchers.define :validate_presence_of do |field_name|
  match do |subject|
    subject[field_name] = nil
    !subject.valid?
  end
end

RSpec::Matchers.define :send_email do |email|
  match do |controller|
    EmailGateway.should_receive(:send_email).with nil
  end
end
