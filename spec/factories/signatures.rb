FactoryGirl.define do
  factory :signature do
    petition
    ip_address { Faker::Internet.ip_v4_address }
    user_agent 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.163 Safari/535.19'
    browser_name 'chrome'
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    member
  end
end
