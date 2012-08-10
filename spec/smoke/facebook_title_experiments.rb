require 'smoke_spec_helper'
require 'nokogiri'
require 'member_hasher'

# describe "creating a facebook title experiment" do
#   it "awards a win against the facebook title when facebook user signs" do
#     petition = create_a_featured_petition "Multiple facebook titles!", "You betcha", [], ["Subject A", "Subject B"]    

#     #sign petition to trigger spin for fb titles (titles don't spin unless member is identified)
#     go_to petition_path(petition)
#     sign_petition

#     experiment = facebook_experiment_results_for petition
#     experiment.spins.should == 1
#     experiment.wins.should == 0

#     link_from_fb = facebook_referral_link petition, current_member
#     delete_member_cookie
#     go_to link_from_fb
#     sign_petition

#     experiment = facebook_experiment_results_for petition
#     experiment.spins.should == 1
#     experiment.wins.should == 1
#   end

#   pending "editing subject should start a new test" do
#     # go back to editing your petition
#     # change both of the facebook titles
#     # save
#     # create a new member
#     # visit and sign petition (as that new member)
#     # visit /admin/experiments (as admin)
#     # make sure the number of spins is 1 and wins 1 for the old title
#     # make sure the number of spins is 1 for a new title
#   end
# end


# def facebook_experiment_results_for petition
#   as_admin do
#     go_to 'admin/experiments'
#     table = element(xpath: "//table[@id = 'petition #{petition.id} facebook title']")
#     spins = table.find_element(xpath: "tbody/tr/td[@class='spins']").text.to_i
#     wins = table.find_element(xpath: "tbody/tr/td[@class='wins']").text.to_i
#     return OpenStruct.new(spins: spins, wins: wins)
#   end
# end

# def facebook_referral_link petition, member
#   "#{petition_path(petition)}?rfbm=#{member.to_hash}"
# end
