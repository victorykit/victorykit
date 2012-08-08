FactoryGirl.define do
  factory :facebook_request do
    member factory: :member
    petition factory: :petition
    sequence :action_id do |n|
        n.to_s
      end
  end
end
