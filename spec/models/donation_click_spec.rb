require 'spec_helper'

describe DonationClick do
  
  subject { create(:donation_click) }
  it { should be_a(DonationClick) }
  
end