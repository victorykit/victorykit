# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :share do
    member factory: :member
    petition factory: :petition
    sequence :action_id do |n|
        n.to_s
      end
  end
end
