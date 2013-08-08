describe ScheduledMailer do

  before(:each) do
    guard_against_spins EmailExperiments
  end

  def stub_experiment_values
    EmailExperiments.any_instance.stub(:subject).and_return("some subject")
    EmailExperiments.any_instance.stub(:image_url).and_return("petition image url")
  end

  describe "sending an email" do
    before { AppSettings["site.list_unsubscribe"] = "unsub@example.com" }
    before { AppSettings["email.from_address"] = "from@example.com" }

    let(:member){ create(:member)}
    let(:petition){ create(:petition, description: "an<br>html&nbsp;&quot;body&quot;and more<br><br>LINK<br><br>and so on")}
    let(:petition_image) {create(:petition_image, petition: petition)}
    let(:mail){ ScheduledMailer.new_petition(petition, member)}
    let(:sent_email){ScheduledEmail.find_by_member_id(member)}
    let(:petition_link){"http://test/petitions/#{petition.id}?n=#{sent_email.to_hash}"}
    let(:referral){"ABC_123"}
    let(:fb_share_url){"http://test/petitions/#{petition.id}?mail_share_ref=#{sent_email.to_hash}"}
    let(:unsubscribe_link){"http://test/unsubscribes/new?n=#{sent_email.to_hash}"}
    let(:pixel_tracking_link){"http://test/pixel_tracking/new?n=#{sent_email.to_hash}"}

    before do
      stub_experiment_values
      Referral.any_instance.stub(:code).and_return(referral)
    end

    it "logs the email" do
      mail
      SentEmail.find_by_member_id(member).petition.should eq petition
    end

    it "includes the petition title in the subject" do
      mail.subject.should eq "some subject"
    end

    it "includes the from" do
      mail.from.should include "from@example.com"
    end

    it "uses the member's email address" do
      mail.to[0].should match(/#{member.email}$/)
    end

    it "includes an image from the petition" do
      mail.body.encoded.should include "petition image url"
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
      mail["List-Unsubscribe"].value.should eq "mailto:unsub+" + sent_email.to_hash + "@example.com"
    end

    it "includes a plain text part" do
      plain_text_part = mail.body.parts.find{|p|p.content_type =~ /text\/plain/}
      plain_text_part.body.should include "an\nhtml \"body\""
    end

    it "substitutes the LINK paragraph with the petition link" do
      mail.body.encoded.should_not include "LINK"
      mail.body.encoded.should include "<br><br><b><a href=\"#{petition_link}\">Click here to sign -- it just takes a second.</a></b><br><br>"
    end

    it "removes the LINK paragraph in plain text part" do
      plain_text_part = mail.body.parts.find{|p|p.content_type =~ /text\/plain/}
      plain_text_part.body.should_not include "LINK"
      plain_text_part.body.should include "and more\n\nand so on"
    end

    it "includes a facebook sharing link" do
      mail.body.encoded.should include fb_share_url
    end
  end

  describe "email send failures" do
    let(:member){ create(:member)}
    let(:petition){ create(:petition)}

    before do
      stub_experiment_values
    end

    it "rolls back transaction" do
      ScheduledMailer.any_instance.stub(:mail).and_raise("stuff")
      ScheduledMailer.new_petition(petition, member)
      SentEmail.last.should be_nil
    end
  end

end
