FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'abcdefgh0987' }
    password_confirmation { password }
    factory :super_user do
      is_super_user true
    end
    factory :admin_user do
      is_admin true
    end
  end
end
