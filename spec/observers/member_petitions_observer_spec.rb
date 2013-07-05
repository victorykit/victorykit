describe MemberPetitionsObserver do
  describe '#after_create' do
    let(:member) { create(:member) }
    let(:petition) { create(:petition) }

    let(:record) { build(:signature, member: member, petition: petition) }

    context "new member" do
      it 'should not re-add petition' do
        member.should_receive(:previous_petition_ids).and_return([petition.id.to_s])
        member.should_not_receive(:add_petition_id)
        MemberPetitionsObserver.instance.after_create(record)
      end
    end

    context "old member with petition_ids" do
      it 'should add petition' do
        member.should_receive(:previous_petition_ids).and_return([(petition.id+1).to_s])
        member.should_receive(:add_petition_id).with(petition.id)
        MemberPetitionsObserver.instance.after_create(record)
      end
    end
  end
end