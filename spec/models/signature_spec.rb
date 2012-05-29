require 'spec_helper'

describe Signature do
  describe "validation" do
    subject { build(:signature) }
    it { should validate_presence_of :email }
    it { should validate_presence_of :name }
    it_behaves_like "email validator"
  end
end
