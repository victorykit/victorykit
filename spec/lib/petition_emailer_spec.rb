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
  it "sends the petition to the member" do
    ScheduledEmail.should_receive(:new_petition).with(petition, member)
    PetitionEmailer.send
  end
end