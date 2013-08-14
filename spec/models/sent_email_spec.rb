describe ScheduledEmail do
  describe "analytics" do
    it "should increment unsubscribe count on create" do
      expect { create(:scheduled_email) }.to change{ $statsd.value_of("emails_sent.count") }.from(0).to(1)
    end
  end

  describe "#track_visit!" do
    subject { build(:scheduled_email) }

    it "should record the time of the visit" do
      expect { subject.track_visit! }.to change{ subject.clicked_at }.from(nil)
    end

    it "should increment emails_clicked" do
      expect { subject.track_visit! }.to change{ $statsd.value_of("emails_clicked.count") }.from(0).to(1)
    end
  end

  context 'after create' do
    subject { build(:scheduled_email) }

    it 'should update the membership stats' do
      subject.member.should_receive :touch_last_emailed_at!
      subject.run_callbacks :create
    end
  end
end
