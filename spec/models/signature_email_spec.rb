require 'spec_helper'

describe SignatureEmail do
  subject { build(:signature_email) }
  its(:type) {should eq "SignatureEmail"}
end