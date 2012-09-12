require 'spec_helper'

describe Petition do

  describe "validation" do
    subject { build(:petition) }
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
    it { should validate_presence_of :owner_id }
    its(:title) { should_not start_or_end_with_whitespace }
  end

  it { should allow_mass_assignment_of(:location).as(:admin) }
  
  it "should find all emailable petitions not yet known to a member" do
    member = create(:member)
    
    signed_petition = create(:petition)
    create(:signature, petition: signed_petition, member: member)

    previously_sent_petition = create(:petition)
    create(:sent_email, petition: previously_sent_petition, member: member)

    new_emailable_petition = create(:petition, to_send: true)
    new_unemailable_petition = create(:petition, to_send: false)
    
    interesting_petitions = Petition.find_interesting_petitions_for(member)
    interesting_petitions.should eq [new_emailable_petition]
  end

  it "should return its experiments" do
    petition = create(:petition)
    petition.experiments.should_not be_nil
  end

  it "should have a plain text description" do
    petition = create(:petition, description: "I<br>contain&nbsp;html &quot;stuff&quot;")
    petition.plain_text_description.should == "I\ncontain html \"stuff\""
  end

  context "facebook description" do
    it "should escape single and double quotes because wysihtml5 doesn't" do
      petition = create(:petition, description: "'\"this description contains quotes")
      petition.facebook_description_for_sharing.should == "&apos;&quot;this description contains quotes"
    end

    it "should strip tags" do
      petition = create(:petition, description: "this description contains a <a href=\"http://woo.com\">link</a>")
      petition.facebook_description_for_sharing.should == "this description contains a link"
    end
  end

  context "description link substitution" do
    it "should substitute br-tagged LINK paragraph with given value" do
      petition = create(:petition, description: "this description has a<br><br>LINK<br><br>paragraph")
      petition.description_lsub("substituted").should == "this description has a<br><br>substituted<br><br>paragraph"
    end

    it "should substitute br-tagged LINK paragraph with blank line given empty string substitution value" do
      petition = create(:petition, description: "this description has a<br><br>LINK<br><br>paragraph")
      petition.description_lsub("").should == "this description has a<br><br>paragraph"
    end

    it "should substitute p-tagged LINK paragraph with given value" do
      petition = create(:petition, description: "<p>this description has a</p><p>LINK</p><p>paragraph</p>")
      petition.description_lsub("substituted").should == "<p>this description has a</p><p>substituted</p><p>paragraph</p>"
    end

    it "should substitute p-tagged LINK paragraph with p break given empty string substitution value" do
      petition = create(:petition, description: "<p>this description has a</p><p>LINK</p><p>paragraph</p>")
      petition.description_lsub("").should == "<p>this description has a</p><p>paragraph</p>"
    end
  end
end
