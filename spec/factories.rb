FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Name.name }
    password_confirmation { password }
    
    factory :super_user do
      is_super_user true
    end
  end
  factory :petition do
    title { Faker::Lorem.words(3) }
    description { Faker::Lorem.paragraphs }
    user
  end
  factory :signature do
    petition
    ip_address { Faker::Internet.ip_v4_address }
    user_agent { Faker::Lorem.words(3) }
    browser_name { Faker::Lorem.words(1) }
    name { Faker::Name.name }
    email { Faker::Internet.email }  
  end
end
