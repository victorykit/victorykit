require 'spec_helper'

describe PixelTrackingController do

  describe "GET show" do
    before do
      create :sent_email, :id => 10, :was_opened => false
      create :sent_email, :id => 11, :was_opened => true
    end

    it "marks sent email as opened in the database" do
       get :show, :id => 10, :format => 'X8MFiS'
       SentEmail.find_by_id(10).was_opened.should == true
    end

    it "doesn`t make any changes if email has already been opened" do
      get :show, :id => 11, :format => 'SG9DJS'
      SentEmail.find(:all).size.should == 2
      SentEmail.find_by_id(11).was_opened.should == true
    end

    it "should not do anything if hash is invalid" do
      get :show, :id => 10, :format => 'invalid'
      SentEmail.find_by_id(10).was_opened.should == false
    end

    it "doesn`t crash if such sent email doesn`t exist" do
      get :show, :id => 12, :format => 'nTErYW'
    end
  end

end




