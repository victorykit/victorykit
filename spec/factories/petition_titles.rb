# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :petition_title do
    title "MyText"
    type "email"
  end
end
