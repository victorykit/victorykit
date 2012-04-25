require 'spec_helper'

describe Petition do
  describe "validation" do
    subject { build(:petition) }
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
    it { should validate_presence_of :owner_id }
  end
  
end
