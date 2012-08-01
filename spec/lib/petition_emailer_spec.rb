require 'spec_helper'
require 'petition_emailer'

describe PetitionEmailer do
  let(:petition){create(:petition, :to_send => true)}
  let(:member){create(:member)}
  it "asks for a random member" do
    Member.should_receive(:random_and_not_recently_contacted).and_return(member)
    PetitionEmailer.send
  end
  it "aborts if no member is found" do
    Member.should_receive(:random_and_not_recently_contacted).and_return(nil)
    ScheduledEmail.should_not_receive(:new_petition)
    PetitionEmailer.send
  end
  it "spins to find a petition" do
    PetitionEmailer.should_receive(:spin!).with("email_scheduler_nps", :signatures_off_email, [petition.id.to_s], {session_id: member.id}).and_return(petition.id.to_s)
    PetitionEmailer.send
  end
  it "aborts if no petitions found" do
    PetitionEmailer.stub(:spin!).and_return nil
    ScheduledEmail.should_not_receive(:new_petition)
    PetitionEmailer.send
  end

  context 'sending scheduled email ' do

    before do
      PetitionEmailer.should_receive(:spin!).with("email_scheduler_nps", :signatures_off_email, [petition.id.to_s()], {session_id: member.id}).and_return(petition.id)
    end

    context 'short summary is present' do
      before do
        petition.update_attributes(:short_summary => "cool")
      end
      it "should send the petition with summary if the spin returns true" do
        should_send_email_with_summary_box true, spin:true
      end
      it "should not draw the summary box if short_summary is present and the spin returns false" do
        should_send_email_with_summary_box false, spin: false
      end
    end
    context 'short summary is not present' do
      it "should not the spin and draw summary box if short_summary is not present" do
        PetitionEmailer.should_not_receive(:spin!).with("insert summary box to emails", :signature)
        ScheduledEmail.should_receive(:new_petition).with(petition, member, false)
        PetitionEmailer.send
      end
    end

    def should_send_email_with_summary_box(is_box_present, opts)
      PetitionEmailer.should_receive(:spin!).with("insert summary box to emails", :signature).and_return(opts[:spin])
      ScheduledEmail.should_receive(:new_petition).with(petition, member, is_box_present)
      PetitionEmailer.send
    end
  end
end
