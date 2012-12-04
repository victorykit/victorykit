describe DonationClick do
  it { should belong_to :member } 
  it { should belong_to :petition } 
  it { should belong_to :referral_code } 
  it { should allow_mass_assignment_of :member }
  it { should allow_mass_assignment_of :petition }
  it { should allow_mass_assignment_of :referral_code }
  it { should allow_mass_assignment_of :amount }
  it { should validate_presence_of :petition }
  it { should validate_presence_of :member }
  it { should validate_presence_of :referral_code }
end
