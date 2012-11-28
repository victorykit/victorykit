describe DonationClick do
  it { should belong_to :member } 
  it { should belong_to :petition } 
  it { should allow_mass_assignment_of :member }
  it { should allow_mass_assignment_of :petition }
  it { should allow_mass_assignment_of :referral_code_id }
  it { should allow_mass_assignment_of :amount }
end
