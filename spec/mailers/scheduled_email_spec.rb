require "spec_helper"

describe ScheduledEmail do
  describe "sending an email" do
    let(:member){ create(:member)}
    let(:petition){ create(:petition)}
    let!(:petition_image) {create(:petition_image, petition: petition)}
    let!(:mail){ ScheduledEmail.new_petition(petition, member)}
    let(:sent_email){SentEmail.find_by_member_id(member)}
    let(:email_hash){SentEmailHasher.generate(sent_email.id)}
    let(:petition_link){"http://test/petitions/#{petition.id}?n=#{email_hash}"}
    let(:unsubscribe_link){"http://test/unsubscribes/new?n=#{email_hash}"}
    let(:pixel_tracking_link){"http://test/pixel_tracking/new?n=#{email_hash}"}
    
    it "logs the email" do
      ScheduledEmail.new_petition(petition, member)
      SentEmail.find_by_member_id(member).petition.should eq petition
    end

    it "includes the petition title in the subject" do
      mail.subject.should include petition.title
    end
    
    it "uses the member's email address" do
      mail.to[0].should match /#{member.email}$/
    end
    
    it "includes an image if any exist" do
      mail.body.encoded.should include "#{petition_image.url}"
    end

    it "includes the petition link in the body" do
      mail.body.encoded.should include petition_link
    end
        
    it "includes an unsubscribe link in the body" do
      mail.body.encoded.should include unsubscribe_link
    end

    it "includes pixel tracking image with correct url" do
      mail.body.encoded.should include "<img src=\"#{pixel_tracking_link}\" />"
    end
    
    it "adds an unsubscribe header" do
      email_hash = SentEmailHasher.generate(sent_email.id)
      mail["List-Unsubscribe"].value.should eq "mailto:unsubscribe+" + email_hash + "@appmail.watchdog.net"
    end
  end

  describe "spinning for subject (default only)" do
    let(:member){ create(:member)}
    let(:petition){ create(:petition)}
    let!(:mail){ ScheduledEmail.new_petition(petition, member)}

    it "picks the petition title by default" do
      mail.subject.should eq petition.title
    end
  end

  describe "spinning for subject (one subject)" do
    let(:member){ create(:member)}
    let(:petition){ create(:petition)}
    let!(:title){ p = PetitionTitle.new(title_type: PetitionTitle::TitleType::EMAIL, title: "foo"); p.petition_id = petition.id; p.save }
    let!(:mail){ ScheduledEmail.new_petition(petition, member)}

    it "picks an email subject if there is one" do
      mail.subject.should eq "foo"
    end
  end

  describe "spinning for subject (two subjects)" do
    let(:member){ create(:member)}
    let(:petition){ create(:petition)}
    let!(:title){ p = PetitionTitle.new(title_type: PetitionTitle::TitleType::EMAIL, title: "foo"); p.petition_id = petition.id; p.save }
    let!(:title2){ p = PetitionTitle.new(title_type: PetitionTitle::TitleType::EMAIL, title: "foo2"); p.petition_id = petition.id; p.save }
    let!(:mail){ ScheduledEmail.new_petition(petition, member)}

    it "picks an email subject if there is one" do
        mail.subject.should be_in ["foo", "foo2"]
    end
  end

  describe "summary box experiment" do
    let(:member){ create(:member)}
    
    context "short_summary is present" do
      let(:petition){ create(:petition, :short_summary => "short summary")}
      it "should insert short_summary box to the email if the spin returned true" do
        EmailExperiments.any_instance.should_receive(:summary_box).and_return true
        mail = ScheduledEmail.new_petition(petition, member)
        mail.body.encoded.should include "short summary"
      end

      it "should not insert short_summary box to the email if the spin returned false" do
        EmailExperiments.any_instance.should_receive(:summary_box).and_return false
        mail = ScheduledEmail.new_petition(petition, member)
        mail.body.encoded.should_not include "short summary"
      end
    end

    context 'short summary is not present' do
      let(:petition){ create(:petition) }
      
      it "should not insert short_summary box to the email and it should not spin" do
        EmailExperiments.any_instance.should_not_receive(:summary_box)
        mail = ScheduledEmail.new_petition(petition, member)
        mail.body.encoded.should_not include "Sign the petition!"
      end
    end
  end
end
