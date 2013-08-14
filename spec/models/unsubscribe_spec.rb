describe Unsubscribe do
  it { should validate_presence_of :email }
  it { should be_a Unsubscribe }

  describe '.unsubscribe_member' do
    subject { Unsubscribe.unsubscribe_member(Member.new) }
    it { should_not be_nil }
    its(:cause) { should == 'unsubscribed' }
  end

  context 'analytics' do
    specify do
      expect { create(:unsubscribe) }.
      to change{ $statsd.value_of('unsubscribes.count') }.from(0).to(1)
    end
  end

  context 'after create' do
    let(:signature) { create :signature }
    before  { Unsubscribe.unsubscribe_member(signature.member) }
    specify { expect(signature.member.reload.membership).to be_blank }
  end
end
