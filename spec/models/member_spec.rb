require 'spec_helper'

describe Member do
  describe 'instance' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :email }

    describe '#has_signed?' do
      let(:petition) { stub(:id => 42) }
      before { subject.stub_chain(:signatures, :where).and_return [signature] }

      context 'before signing a petition' do
        let(:signature) { nil }
        it { should_not have_signed petition }
      end

      context 'after signing a petition' do
        let(:signature) { anything }
        it { should have_signed petition }
      end
    end

    describe '#to_hash' do
      let(:id) { subject.id }
      before { MemberHasher.stub!(:generate).with(id).and_return 'foo' }
      specify { subject.to_hash.should eql 'foo' }
    end
  end

  describe 'class' do
    subject { Member }
    let(:member) { create :member }

    describe '.find_by_hash' do
      let(:id) { member.id }
      before { MemberHasher.stub!(:validate).with('foo').and_return id }
      specify { subject.find_by_hash('foo').should eql member }
    end

    describe '#random_and_not_recently_contacted' do

      shared_examples 'ignoring them' do
        specify { subject.random_and_not_recently_contacted.should be_nil }
      end

      context 'for recently contacted members' do
        before { create :sent_email, member: member }
        it_behaves_like 'ignoring them'
      end

      context 'for unsubscribed members' do
        before { create :unsubscribe, member: member }
        it_behaves_like 'ignoring them'
      end

      context 'for members contacted more than a week ago' do
        before { create :sent_email, created_at: 8.days.ago, member: member }
        specify { subject.random_and_not_recently_contacted.should eql member }
      end
      
    end

  end

end