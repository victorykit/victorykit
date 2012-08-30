describe PetitionStatistics do
  subject { PetitionStatistics.new(petition, google_data, local_data) }
  
  let(:local_data) { OpenStruct.new(signatures: 1, new_members: 0) }
  let(:petition) { build(:petition_with_signatures, signature_count: 1) }
  let(:google_data) { OpenStruct.new(unique_pageviews: '100') }
  
  describe 'when statistics are available' do
    its(:hit_count) { should eq 100 }
    its(:signature_count) { should eq  1 }
    its(:new_member_count) { should eq  0 }
  end

  describe 'when statistics are unavailable' do
    let(:google_data) { nil }
    
    its(:hit_count) { should eq 0 }
    its(:signature_count) { should eq  1 }
    its(:new_member_count) { should eq  0 }
  end

  describe '#divide_safe' do
    specify { subject.divide_safe(10, 2).should eq 5 }
    specify { subject.divide_safe(10, 0).should eq 0 }
  end
end
