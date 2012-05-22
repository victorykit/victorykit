require 'spec_helper'

describe PetitionsDatatable do
  let(:petitions){ [1,2].map {|i|create(:petition, :title => i.to_s)}}
  let(:context){ double "view_context" }
  let(:builder){ double "petitions_statistics_builder" }
  
  it "converts analytics for each petition to JSON" do
    #this is horrible.  sorry.  it will get better.
    def hstub(x)
      context.stub(:h).with(x).and_return(x)
      context.stub(:float_to_percentage).with(x).and_return(x)
      context.stub(:format_date_time).with(x).and_return(x)
    end
    
    context.stub(:params).and_return({:since => Date.today, :sEcho => "1", :iDisplayLength => "1"})
    
    builder.stub(:all_since_and_ordered) {petitions.map {|p| analytics_for(p)}}
    
    builder.all_since_and_ordered.each do |stat|
      context.stub(:link_to).with(stat.petition_title, stat.petition_record).and_return("link to #{stat.petition_title}")
      hstub(stat.hit_count)
      hstub(stat.signature_count)
      hstub(stat.conversion_rate)
      hstub(stat.signature_count)
      hstub(stat.email_count)
      hstub("#{stat.opened_emails_count} (#{stat.opened_emails_percentage})")
      hstub(stat.opened_emails_percentage)
      hstub(stat.email_signature_count)
      hstub(stat.email_conversion_rate)
      hstub(stat.new_member_count)
      hstub(stat.virality_rate)
      hstub(stat.petition_created_at)
    end
    
    #totals row
    hstub 'All Petitions'
    hstub 2
    hstub 2
    hstub 1
    hstub 2
    hstub 20
    hstub "12 (0.6)"
    hstub 2
    hstub 10
    hstub 0.1
        
    json = PetitionsDatatable.new(context, builder).as_json
    puts json
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
      :opened_emails_count => 6,
      :opened_emails_percentage => 0.6,
      :email_signature_count => 1,
      :email_conversion_rate => 10,
      :virality_rate => 1,
      :new_member_count => 1,
      :petition_created_at => Date.today,
      :petition_record => petition)
  end
end
