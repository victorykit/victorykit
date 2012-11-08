FactoryGirl.define do
  factory :petition_summary do
    petition
    short_summary {Faker::Lorem.sentence}
  end
end