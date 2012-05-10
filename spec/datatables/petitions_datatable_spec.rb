require 'spec_helper'

describe PetitionsDatatable do
  let(:petitions){ [1,2].map {|i|create(:petition, :title => i.to_s)}}
  let(:context){ double "view_context" }
  let(:analyzer){ double "petitions_analyzer" }
  
  it "converts analytics for each petition to JSON" do
    context.stub(:params).and_return({:since => Date.today, :sEcho => "1"})
    
    analyzer.stub(:all_since_and_ordered) {petitions.map {|p| analytics_for(p)}}
    analyzer.all_since_and_ordered.each do |stat|
      context.stub(:link_to).with(stat.petition_title, stat.petition_record).and_return("link to #{stat.petition_title}")
      context.stub(:h).with(stat.hit_count).and_return(stat.hit_count)
      context.stub(:h).with(stat.signature_count).and_return(stat.signature_count)
      context.stub(:float_to_percentage).with(stat.conversion_rate).and_return(stat.conversion_rate)
      context.stub(:h).with(stat.conversion_rate).and_return(stat.conversion_rate)
      context.stub(:h).with(stat.new_member_count).and_return(stat.new_member_count)
      context.stub(:float_to_percentage).with(stat.virality_rate).and_return(stat.virality_rate)
      context.stub(:h).with(stat.virality_rate).and_return(stat.virality_rate)
      context.stub(:format_date_time).with(stat.petition_created_at).and_return(stat.petition_created_at)
      context.stub(:h).with(stat.petition_created_at).and_return(stat.petition_created_at)
    end
    
    json = PetitionsDatatable.new(context, analyzer).as_json
    json[:iTotalRecords].should == petitions.size
    #TODO (maybe) assert on JSON contents?  It gets ugly quick
  end
  
  def analytics_for(petition)
    double("petition_analytic", 
      :hit_count => 1,
      :petition_title => petition.title,
      :signature_count => 1,
      :conversion_rate => 100,
      :virality_rate => 1,
      :new_member_count => 1,
      :petition_created_at => Date.today,
      :petition_record => petition)
  end
end