require 'spec_helper'

describe PetitionStatistics do
  
  describe "when statistics are available" do        
    let(:data) { OpenStruct.new(:unique_pageviews=>"100") }
    let(:petition) { create(:petition_with_signatures, signature_count: 75) }
    subject { PetitionStatistics.new(petition, data, Date.today) }
    
    its(:hit_count) { should == 100 }
    its(:signature_count) { should ==  75 }
    its(:new_member_count) { should ==  0 }
  end

  describe "when statistics are unavailable" do        
    let(:petition) { create(:petition_with_signatures, signature_count: 75) }
    subject { PetitionStatistics.new(petition, nil, Date.today) }
    
    its(:hit_count) { should == 0 }
    its(:signature_count) { should ==  75 }
    its(:new_member_count) { should ==  0 }    
  end
  
  describe "when a date is given" do
    let(:data) { OpenStruct.new(:unique_pageviews=>"100") }
    let(:petition) { create(:petition_with_one_signature_per_day_since_last_month) }
    subject { PetitionStatistics.new(petition, data, Date.today - 9) }
    
    its(:signature_count) { should ==  10 }
  end
end
