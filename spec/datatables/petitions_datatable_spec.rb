require 'spec_helper'

describe PetitionsDatatable do
  let(:petition){ create(:petition, :title => "a petition")}
  let(:builder){ double "petitions_statistics_builder" }
  
  it "converts analytics for each petition to JSON" do
    stats = analytics_for petition
    builder.stub(:all_since_and_ordered) {[stats]}
    context = StubViewContext.new
    json = PetitionsDatatable.new(context, builder).as_json
    json[:aaData].first.should == 
    [
      "link to #{stats.petition_title}", 
      stats.hit_count, 
      stats.signature_count, stats.conversion_rate, 
      stats.email_count, 
      "#{stats.opened_emails_count} (#{stats.opened_emails_percentage})",
      stats.email_signature_count, 
      stats.email_conversion_rate, 
      stats.virality_rate, 
      stats.new_member_count, 
      "#{stats.likes} (#{stats.likes_percentage})",
      stats.petition_created_at
    ]
    
    json[:iTotalRecords].should == 1
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
      :likes => 1,
      :likes_percentage => 100,
      :petition_created_at => Date.today,
      :petition_record => petition)
  end
end

class StubViewContext
  def params
    {:since => Date.today}
  end
  def link_to a, b
    "link to #{a}"
  end
  def h thing
    thing
  end
  def float_to_percentage f
    f
  end
  def format_date_time d
    d
  end
end
