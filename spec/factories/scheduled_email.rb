FactoryGirl.define do
  factory :scheduled_email do
    petition
    member
    email {Faker::Internet.email}
  end
end

