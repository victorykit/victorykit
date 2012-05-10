require 'spec_helper'

describe PetitionStatistics do
  
  describe "when statistics are available" do        
    let(:data) { OpenStruct.new(:pageviews=>"100") }
    let(:petition) { create(:petition_with_signatures, signature_count: 75) }
    subject { PetitionStatistics.new(petition, data) }
    
    its(:hit_count) { should == 100 }
    its(:signature_count) { should ==  75 }
    its(:conversion_rate) { should ==  0.75 }
    its(:new_member_count) { should ==  0 }
    its(:virality_rate) { should ==  0.0 }
  end

  describe "when statistics are unavailable" do        
    let(:petition) { create(:petition_with_signatures, signature_count: 75) }
    subject { PetitionStatistics.new(petition, nil) }
    
    its(:hit_count) { should == 0 }
    its(:signature_count) { should ==  75 }
    its(:conversion_rate) { should ==  0.0 }
    its(:new_member_count) { should ==  0 }
    its(:virality_rate) { should ==  0.0 }
  end
  
  
  
end
