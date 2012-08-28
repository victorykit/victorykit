require 'spec_helper'

describe PixelTrackingController do

  describe "GET new" do
    before do
      @time_now = Time.now
      Time.stub!(:now).and_return(@time_now)
    end

    it "marks sent email as opened in the database" do
      email = create :sent_email, :opened_at => nil
      get :new, :n => email.to_hash
      email.reload.opened_at.to_i.should == @time_now.to_i
    end

    it "doesn`t make any changes if email has already been opened" do
      onedayago = 1.day.ago
      email = create :sent_email, :opened_at => onedayago
      get :new, :n => email.to_hash
      email.reload.opened_at.to_i == onedayago.to_i
    end

    it "should not do anything if hash is invalid" do
      email = create :sent_email, :opened_at => nil
      get :new, :n => "#{email.id}.invalid"
      email.reload.opened_at.should be(nil)
    end

    it "doesn`t crash if such sent email doesn`t exist" do
      hash = build(:sent_email, id: 12).to_hash
      get :new, :n => hash
    end
  end

end
