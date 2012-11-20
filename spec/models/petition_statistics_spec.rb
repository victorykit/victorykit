describe PetitionStatistics do
  subject { PetitionStatistics.new(petition, google_data, local_data) }
  
  let(:petition) { build(:petition_with_signatures, signature_count: 1) }
  let(:local_data) { OpenStruct.new(signatures: 1, new_members: 0) }
  let(:google_data) { OpenStruct.new(unique_pageviews: '100') }
  
  context 'statistics are available' do
    its(:hit_count) { should eq 100 }
    its(:signature_count) { should eq  1 }
    its(:new_member_count) { should eq  0 }
  end

  context 'statistics are unavailable' do
    let(:google_data) { nil }
    its(:hit_count) { should eq 0 }
    its(:signature_count) { should eq  1 }
    its(:new_member_count) { should eq  0 }
  end

  describe '#divide_safe' do
    specify { subject.divide_safe(10, 2).should eq 5 }
    specify { subject.divide_safe(10, 0).should eq 0 }
  end

  describe '#likes_count' do
    before do
      FacebookAction.stub(:where).
        with(:petition_id => petition).
        and_return(3.times.map{ stub })
    end
    its(:likes_count) { should == 3 }
  end
end
