require 'spec_helper'
require 'hasher'

describe Hasher do
  describe "Hasher generate" do
    it "should validate a hash" do
      number = '100'
      hashed_number = Hasher.generate(number)
      Hasher.validate(hashed_number).should be_true
    end
  end
end