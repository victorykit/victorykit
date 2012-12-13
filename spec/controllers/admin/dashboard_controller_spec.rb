describe Admin::DashboardController do
  before do
    create(:donation, amount: 10.0, created_at: 2.days.ago)
    create(:donation, amount: 10.0, created_at: 3.days.ago)
    create(:donation, amount: 10.0, created_at: 4.days.ago)
    create(:donation, amount: 10.0, created_at: 5.days.ago)
    create(:donation, amount: 10.0, created_at: 6.days.ago)
    create(:donation, amount: 10.0, created_at: 7.days.ago)
    create(:donation, amount: 10.0, created_at: 8.days.ago)
  end

  its(:average_donations_per_day) {should eq 10.0}
end
