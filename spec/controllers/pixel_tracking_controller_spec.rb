require 'spec_helper'

describe PixelTrackingController do

  describe "GET new" do
    before do
      create :sent_email, :id => 37, :was_opened => false
      create :sent_email, :id => 11, :was_opened => true
    end

    it "marks sent email as opened in the database" do
       get :new, :n => Hasher.generate(37)
       SentEmail.find_by_id(37).was_opened.should == true
    end

    it "doesn`t make any changes if email has already been opened" do
      get :new, :n => Hasher.generate(11)
      SentEmail.find(:all).size.should == 2
      SentEmail.find_by_id(11).was_opened.should == true
    end

    it "should not do anything if hash is invalid" do
      get :new, :n => '37.invalid'
      SentEmail.find_by_id(37).was_opened.should == false
    end

    it "doesn`t crash if such sent email doesn`t exist" do
      $stdout.stub(:write)
      get :new, :n => Hasher.generate(12)
    end
  end

end




