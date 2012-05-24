require 'spec_helper'

describe PixelTrackingController do

  describe "GET new" do
    before do
      time_now = Time.now
      Time.stub!(:now).and_return(time_now)

      create :sent_email, :id => 37
      create :sent_email, :id => 11, :opened_at => Time.now - 1.day
    end

    #todo: resolve local/integration inconsistency with 
    #  SentEmail.find_by_id(37).opened_at.should == Time.now
    #Seems == works locally (for mandersen) but on railsonfire fails with:
    #  expected: 2012-05-24 03:44:11 UTC
    #  got: Thu, 24 May 2012 03:44:11 UTC +00:00 (using ==)
    #using < and + 1.minute sorts it out, but isn't especially clear
    #Note that:
    #Time.now      produces something like:  2012-05-23 22:22:00 -0600 
    #DateTime.now  produces something like:  Wed, 23 May 2012 22:22:08 -0600
    it "marks sent email as opened in the database" do
       get :new, :n => Hasher.generate(37)
       SentEmail.find_by_id(37).opened_at.should < Time.now + 1.minute
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