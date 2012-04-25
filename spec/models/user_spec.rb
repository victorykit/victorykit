require 'spec_helper'

describe User do
  describe "validation" do
    subject { build(:user) }
    it { should validate_presence_of :email }
  end
end
