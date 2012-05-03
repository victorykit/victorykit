require 'spec_helper'
require 'hasher'

describe Hasher do
  describe "Hasher generate" do
    it "should validate a hash" do
      number = 100
      hashed_number = Hasher.generate(number)
      Hasher.validate(hashed_number).should == number
    end
    it "should return false for invalid hash" do
      Hasher.validate('fake_hashed_number').should be_false
    end
    it "should return false for nil" do
      Hasher.validate(nil).should be_false
    end
  end
end