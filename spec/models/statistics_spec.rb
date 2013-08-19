describe Statistics do

  context "donation totals" do
    subject { Statistics.new }

    context "with no donations" do
      specify { expect(subject.total_donations).to eq(0.0) }
    end

    context "with multiple donations" do
      before { 3.times { create :donation, amount: 10.0 } }
      specify { expect(subject.total_donations).to eq(30.0) }
    end
  end

  context "donation averages" do
    subject { Statistics.new }

    context "with no donations" do
      specify { expect(subject.average_donations_per_day).to eq(0.0) }
    end

    context "with multiple donations" do
      before { 7.times { create :donation, amount: 10.0, created_at: 2.days.ago } }
      specify { expect(subject.average_donations_per_day).to eq(10.0) }
    end
  end

end
