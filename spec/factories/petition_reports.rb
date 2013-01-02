FactoryGirl.define do
  factory :petition_report do
    petition_title { Faker::Lorem.sentence }
  end
end