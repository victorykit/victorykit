RSpec::Matchers.define :validate_presence_of do |field_name|
  match do |subject|
    subject[field_name] = nil
    !subject.valid?
  end
end

RSpec::Matchers.define :send_email do |from, to, subject, body|
  match do |controller, email_gateway|
    email_gateway.last_email_sent.from.should == from
    email_gateway.last_email_sent.to.should == to
    email_gateway.last_email_sent.subject.should == subject
    email_gateway.last_email_sent.body.should == body
  end
end
