describe Metrics::Nps do

  before(:each) do  
    @month = 1.month.ago
    @week = 1.week.ago
    @day = 1.day.ago

    @petition_a = create(:petition, to_send: true, created_at: @month)
    @petition_b = create(:petition, to_send: true, created_at: @week)
    @petition_c = create(:petition, to_send: true, created_at: @day)
    @petition_unfeatured = create(:petition, to_send: false, created_at: @month)

    @member_old = create(:member)
    @member_x = create(:member)
    @member_y = create(:member)
    @member_z = create(:member)

    # petition_a: send, sign, unsubscribe
    @sent_aold = create(:scheduled_email, member: @member_old, petition: @petition_a, created_at: @month)
    @sent_ax = create(:scheduled_email, petition: @petition_a, member: @member_x, created_at: @month)
    @sent_ay = create(:scheduled_email, petition: @petition_a, member: @member_y, created_at: @month)
    @sent_az = create(:scheduled_email, petition: @petition_a, member: @member_z, created_at: @week)

    @signature_aold = create(:signature, petition: @petition_a, member: @member_old, created_member: false, created_at: @month)
    @signature_ax = create(:signature, petition: @petition_a, member: @member_x, created_member: true, created_at: @month)
    @signature_ay = create(:signature, petition: @petition_a, member: @member_y, created_member: true, created_at: @week)

    @unsubscribe_az = create(:unsubscribe, member: @member_z, sent_email: @sent_az, created_at: @day, cause: "unsubscribed")

    # petition_b: send, sign, unsubscribe
    @sent_bx = create(:scheduled_email, petition: @petition_b, member: @member_x, created_at: @week)
    @signature_bx = create(:signature, petition: @petition_b, member: @member_x, created_member: true, created_at: @day)

    # petition_unfeatured: send, sign, unsubscribe
    # petition could have been featured, then un-featured. 
    # could have led to a new member signature, but should still be excluded from timeframe queries
    @sent_unfeaturedold = create(:scheduled_email, petition: @petition_unfeatured, member: @member_old, created_at: @month)
    @signature_unfeaturedold = create(:signature, petition: @petition_unfeatured, member: @member_old, created_member: true, created_at: @month)
    
  end

  it "should calculate nps for a single petition" do
    nps = Metrics::Nps.new.single @petition_a
    nps[:sent].should eq 4
    nps[:subscribes].should eq 2
    nps[:unsubscribes].should eq 1
    nps[:nps].should eq 0.25
  end

  it "should calculate nps for each petition" do
    nps = Metrics::Nps.new.multiple [@petition_a, @petition_b]
    nps.count.should eq 2

    nps_a = find_for @petition_a, nps
    nps_a[:sent].should eq 4
    nps_a[:subscribes].should eq 2
    nps_a[:unsubscribes].should eq 1
    nps_a[:nps].should eq 0.25

    nps_b = find_for @petition_b, nps
    nps_b[:sent].should eq 1
    nps_b[:subscribes].should eq 1
    nps_b[:unsubscribes].should eq 0
    nps_b[:nps].should eq 1.0
  end

  context "aggregate" do

    it "should calculate nps in aggregate over a month" do
      nps = Metrics::Nps.new.aggregate @month-1.second
      nps[:sent].should eq 6
      nps[:subscribes].should eq 4
      nps[:unsubscribes].should eq 1
      nps[:nps].should eq 0.5
    end

    it "should calculate nps in aggregrate over a week" do
      nps = Metrics::Nps.new.aggregate @week-1.second
      nps[:sent].should eq 2
      nps[:subscribes].should eq 2
      nps[:unsubscribes].should eq 1
      nps[:nps].should eq 0.5
    end

  end

  context "timespan" do
    
    it "should calculate nps per item over a month" do
      nps = Metrics::Nps.new.timespan @month - 1.second, 0
      nps.count.should eq 2

      a = find_for @petition_a, nps
      a[:sent].should eq 4
      a[:subscribes].should eq 2
      a[:unsubscribes].should eq 1
      a[:nps].should eq 0.25

      b = find_for @petition_b, nps
      b[:sent].should eq 1
      b[:subscribes].should eq 1
      b[:unsubscribes].should eq 0
      b[:nps].should eq 1.0
    end

    it "should calculate nps per item over a week" do
      nps = Metrics::Nps.new.timespan @week - 1.second, 0
      nps.count.should eq 2

      a = find_for @petition_a, nps
      a[:sent].should eq 1
      a[:subscribes].should eq 1
      a[:unsubscribes].should eq 1
      a[:nps].should eq 0.0

      b = find_for @petition_b, nps
      b[:sent].should eq 1
      b[:subscribes].should eq 1
      b[:unsubscribes].should eq 0
      b[:nps].should eq 1.0
    end

  end

  def find_for p, nps
    nps.find{|n| n[:petition_id] == p.id}
  end

end
