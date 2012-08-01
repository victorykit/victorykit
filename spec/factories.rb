FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Name.name }
    password_confirmation { password }    
    factory :super_user do
      is_super_user true
    end
    factory :admin_user do
      is_admin true
    end
  end
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
  factory :signature do
    petition
    ip_address { Faker::Internet.ip_v4_address }
    user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.163 Safari/535.19"
    browser_name "Firefox"
    name { Faker::Name.name }
    email { Faker::Internet.email }
    member
  end
  factory :petition_analysis do
    pageviews 200
  end
  factory :sent_email do
    petition
    member
    email {Faker::Internet.email}
  end
  factory :social_media_trial do
    petition
    member
    choice { Faker::Lorem.sentence }
    goal { :signature }
    key { Faker::Lorem.sentence }
  end
end
