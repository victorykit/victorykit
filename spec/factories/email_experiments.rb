# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_experiment do
    sent_email_id 1
    goal "MyString"
    key "MyString"
    choice "MyString"
  end
end
