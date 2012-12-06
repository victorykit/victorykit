FactoryGirl.define do
  factory :petition do |f|
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    owner factory: :user
    factory :petition_with_signatures do
      ignore do
        signature_count 10
      end
      after(:create) do |petition, evaluator|
        FactoryGirl.create_list(:signature, evaluator.signature_count, petition: petition)
      end
    end
    factory :petition_with_one_signature_per_day_since_last_month do
      after(:create) do |petition, evaluator|
        today = Date.today
        last_month = today << 1

        (last_month..today).to_a.each do |create_date|
          FactoryGirl.create(:signature, created_at: create_date,petition: petition)
        end
      end
    end
  end
end
