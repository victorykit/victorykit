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

  describe '.to_csv' do
    let(:john) do
      create :member, 
        :first_name => 'John', 
        :last_name => 'Doe', 
        :email => 'jd@gmail.com'
    end
    let(:unsubscription) { Unsubscribe.new(:member => john) }
    before { Unsubscribe.stub(:all).and_return [unsubscription] }
    subject { Unsubscribe.to_csv }
    it { should == "Email,Name\njd@gmail.com,John Doe\n" }
  end
end
