FactoryGirl.define do
	factory :petition_image do
		petition
		url {Faker::Internet.url}
	end
end