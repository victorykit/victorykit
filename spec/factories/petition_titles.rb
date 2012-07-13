# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :petition_title do
    petition
    title {Faker::Lorem.sentence}
    title_type "email"
  end
end
