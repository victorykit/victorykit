# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :unsubscribe do
    member
    email { Faker::Internet.email }
  end
end
