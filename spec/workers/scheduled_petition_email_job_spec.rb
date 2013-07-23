
describe ScheduledPetitionEmailJob do
  it { should respond_to :perform}

  context "some data" do
    let(:petition) { Factory.create(:petition)}
    let(:member) { Factory.create(:member) }

    it "should send a petition email to the member" do
      ScheduledMailer.should_receive(:new_petition).with(petition, member)
      ScheduledPetitionEmailJob.new.perform(member.id, [petition.id])
    end
  end

end
