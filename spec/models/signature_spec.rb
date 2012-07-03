require 'spec_helper'

describe Signature do
  context "validation" do
    subject { build(:signature) }
    it { should validate_presence_of :email }
    it { should validate_presence_of :name }
    it_behaves_like "email validator"
  end

  context "given a really long user agent" do
    it "truncates it to 255 characters" do
      signature = build(:signature, user_agent: "0" * 512)
      signature.save!
      signature.user_agent.length.should == 255
    end
  end

  it "should allow only predefined types of references" do
    Signature.new(:name => "bob" , :email => "a@a.com", :reference_type => "facebook_like").valid?.should == true
    Signature.new(:name => "bob" , :email => "a@a.com", :reference_type => "email" ).valid?.should == true
    Signature.new(:name => "bob" , :email => "a@a.com", :reference_type => "twitter" ).valid?.should == true
    Signature.new(:name => "bob" , :email => "a@a.com", :reference_type => "wrong" ).valid?.should == false
  end
end
