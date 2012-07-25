# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

5.times { FactoryGirl.create(:petition) }

100.times do
  all_petitions = Petition.all
  FactoryGirl.create(:signature, petition: all_petitions.sample) 
end

FactoryGirl.create(:super_user, email:"admin@victorykit.com", password: "password") unless User.find_by_email "admin@victorykit.com"
MailerProcessTracker.create! :is_locked => false
