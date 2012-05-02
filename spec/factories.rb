FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Name.name }
    password_confirmation { password }    
    factory :super_user do
      is_super_user true
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
      after_create do |petition, evaluator|
        FactoryGirl.create_list(:signature, evaluator.signature_count, petition: petition)
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
  
end
