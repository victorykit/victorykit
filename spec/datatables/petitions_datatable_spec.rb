require 'spec_helper'

describe PetitionsDatatable do
  let(:petitions){ [1,2].map {|i|create(:petition, :title => i.to_s)}}
  let(:context){ double "view_context" }
  let(:analyzer){ double "petitions_analyzer" }
  
  it "converts analytics for each petition to JSON" do
    context.stub(:params).and_return({:since => Date.today, :sEcho => "1", :iDisplayLength => "1"})
    
    analyzer.stub(:all_since_and_ordered) {petitions.map {|p| analytics_for(p)}}
    analyzer.all_since_and_ordered.each do |stat|
      def hstub(x)
        context.stub(:h).with(x).and_return(x)
        context.stub(:float_to_percentage).with(x).and_return(x)
        context.stub(:format_date_time).with(x).and_return(x)
      end
      context.stub(:link_to).with(stat.petition_title, stat.petition_record).and_return("link to #{stat.petition_title}")
      hstub(stat.hit_count)
      hstub(stat.signature_count)
      hstub(stat.conversion_rate)
      hstub(stat.signature_count)
      hstub(stat.email_count)
      hstub(stat.email_signature_count)
      hstub(stat.email_conversion_rate)
      hstub(stat.new_member_count)
      hstub(stat.virality_rate)
      hstub(stat.petition_created_at)
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
      :email_count => 10,
      :email_signature_count => 1,
      :email_conversion_rate => 10,
      :virality_rate => 1,
      :new_member_count => 1,
      :petition_created_at => Date.today,
      :petition_record => petition)
  end
end