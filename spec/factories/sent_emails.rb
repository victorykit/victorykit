FactoryGirl.define do
  factory :sent_email do
    petition
    member
    email {Faker::Internet.email}
  end
end
