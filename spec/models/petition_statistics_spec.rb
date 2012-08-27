require 'spec_helper'

describe PetitionStatistics do
  let(:google_data) { OpenStruct.new(:unique_pageviews=>"100") }
  let(:local_data) { OpenStruct.new(:signatures => 1, :new_members => 0) }
  let(:petition) { create(:petition_with_signatures, signature_count: 1) }
  
  describe "when statistics are available" do
    subject { PetitionStatistics.new(petition, google_data, local_data) }
    
    its(:hit_count) { should == 100 }
    its(:signature_count) { should ==  1 }
    its(:new_member_count) { should ==  0 }
  end

  describe "when statistics are unavailable" do        
    subject { PetitionStatistics.new(petition, nil, local_data) }
    
    its(:hit_count) { should == 0 }
    its(:signature_count) { should ==  1 }
    its(:new_member_count) { should ==  0 }
  end
end
