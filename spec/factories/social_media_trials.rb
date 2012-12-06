FactoryGirl.define do
  factory :social_media_trial do
    petition
    member
    choice { Faker::Lorem.sentence }
    goal { :signature }
    key { Faker::Lorem.sentence }
  end
end
