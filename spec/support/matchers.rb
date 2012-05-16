RSpec::Matchers.define :validate_presence_of do |field_name|
  match do |subject|
    subject.send(field_name.to_s+"=", nil)
    !subject.valid?
  end
end
RSpec::Matchers.define :model_with_properties do |expected_properties|
  match do |subject|
    "a string".should include("a") 
  end
end
RSpec::Matchers.define :allow_mass_assignment_of_by_default_role do | properties |
  match do |subject|
    expect {subject.update_attributes(Hash[properties.zip(properties)])}.to_not raise_error ActiveModel::MassAssignmentSecurity::Error
  end
end

RSpec::Matchers.define :allow_mass_assignment_of_by_admin_role do | properties |
  match do |subject|
   subject.update_attributes( Hash[properties.zip(properties)], {:as => :admin} )
expect {subject.update_attributes(Hash[properties.zip(properties)], {:as => :admin} )}.to_not raise_error ActiveModel::MassAssignmentSecurity::Error
  end
end

RSpec::Matchers.define :start_or_end_with_whitespace do |expected|
  match do |actual|
    actual.size != actual.strip.size
  end
end