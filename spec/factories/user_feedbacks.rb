# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_feedback do
    name "I Havefeedback"
    email "me@my.com"
    message "I hate EVERYTHING"
  end
end
