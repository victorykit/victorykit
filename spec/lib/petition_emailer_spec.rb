require 'spec_helper'
require 'petition_emailer'

describe PetitionEmailer do
  let(:member) { create :member }

  describe '#send' do

    context 'when there is a member not recently contacted' do
      before { Member.stub!(:random_and_not_recently_contacted).and_return member }

      it 'should send an email to him' do
        PetitionEmailer.should_receive(:send_to).with(member)
        PetitionEmailer.send
      end
    end

    context 'when all members were recently contacted' do
      before { Member.stub!(:random_and_not_recently_contacted) }

      it 'should not send any email' do
        PetitionEmailer.should_not_receive(:send_to)
        PetitionEmailer.send
      end
    end
  end

  describe '#send_to' do

    context 'when there is no interesting petition' do
      before do 
        Petition.stub!(:find_interesting_petitions_for).
        with(member).and_return []
      end

      it 'should not send any email' do
        ScheduledEmail.should_not_receive :new_petition
        PetitionEmailer.send_to member
      end
    end

    context 'when there are interesting petitions' do
      let(:petitions) { [create(:petition)] }
      let(:chosen) { petitions.first }

      before do 
        Petition.stub!(:find_interesting_petitions_for).with(member).and_return petitions
        Petition.stub!(:find_by_id).with(chosen.id).and_return chosen
      end

      it 'should send an email to the member' do
        PetitionEmailer.stub!(:spin_for).and_return chosen.id
        ScheduledEmail.should_receive(:new_petition).with(chosen, member)
        PetitionEmailer.send_to member
      end

      it 'should spin for a petition to send' do
        ScheduledEmail.stub!(:new_petition)

        experiment = 'email_scheduler_nps'
        goal = :signatures_off_email
        options = [chosen.id.to_s]
        session = { session_id: member.id }
        
        PetitionEmailer.should_receive(:spin!).
        with(experiment, goal, options, session).
        and_return chosen.id.to_i
        
        PetitionEmailer.send_to member
      end
    end
  end

end