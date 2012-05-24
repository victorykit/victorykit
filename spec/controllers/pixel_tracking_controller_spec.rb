require 'spec_helper'

describe PixelTrackingController do

  describe "GET new" do
    before do
      time_now = Time.now
      Time.stub!(:now).and_return(time_now)

      create :sent_email, :id => 37
      create :sent_email, :id => 11, :opened_at => Time.now - 1.day
    end

    it "marks sent email as opened in the database" do
       get :new, :n => Hasher.generate(37)
       SentEmail.find_by_id(37).opened_at.should == Time.now
    end

    it "doesn`t make any changes if email has already been opened" do
      get :new, :n => Hasher.generate(11)
      SentEmail.find(:all).size.should == 2
      SentEmail.find_by_id(11).opened_at.should == Time.now - 1.day
    end

    it "should not do anything if hash is invalid" do
      get :new, :n => '37.invalid'
      SentEmail.find_by_id(37).opened_at.should be nil
    end

    it "doesn`t crash if such sent email doesn`t exist" do
      $stdout.stub(:write)
      get :new, :n => Hasher.generate(12)
    end
  end

end