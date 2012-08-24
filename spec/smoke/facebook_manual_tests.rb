require 'smoke_spec_helper'

describe "share on facebook using facebook_popup" do
  before do
    pending "manual steps until automation is figured out"
  end

  #assumptions:
  #test against testserver (fb callbacks won't hit localhost). testserver url must be registered as fb app
  #fb account exists: victorkfb. todo: fb test accounts -> http://developers.facebook.com/docs/test_users/

  #note:
  #we need more than one of the spinnable options, otherwise they aren't tracked as experiments

  #----------
  #sign in to victorykit as admin
  #create a petition: i like turtles
  
  #click: 'Customize Facebook Title'
  #enter an alternate title: fb alt title a
  #enter an alternate title: fb alt title b
  
  #click: 'Customize Facebook Description'
  #enter an alternate description: fb alt desc a
  #enter an alternate description: fb alt desc b

  #click: 'Image Link'
  #enter an image url: www.maniacworld.com/i-lik-turtles.jpg
  #enter an image url: http://i3.kym-cdn.com/photos/images/original/000/181/192/tumblr_ls86k4MTEo1qgs1ido1_400.gif

  #click: 'Create Petition' button
  #note the id of the petition for later use

  #click: log out

  #----------
  #go to /whiplash_sessions (use debug_token if needed)
  #set "facebook sharing options" to facebook_popup
  #click 'update' button

  #go to /petitions/#{id}
  #sign petition

  #click: share on facebook
  #(facebook popup appears)
  #login to facebook as victorkfb if not already logged in
  #click: 'share link' button

  #----------
  #sign in to victorykit as admin
  #go to /admin/experiments?f=petitions

  #check spins against petition #{id} facebook title: 1
  #check wins against petition #{id} facebook title: 0

  #check spins against petition #{id} facebook image: 1
  #check wins against petition #{id} facebook image: 0

  #go to /admin/experiments?f=experiments
  #check wins against facebook sharing options: facebook_popup: 0

  #----------
  #go to facebook (logged in as victorkfb)
  #verify that petition title is alternate title: turtles are awesome
  #verify that petition image is alternate image: www.maniacworld.com/i-lik-turtles.jpg
  #verify that petition description is alternate description: because they have shells

  #----------
  #copy petition link from facebook entry
  #petition link should have a referral param of some sort: share_ref=#{member_hash}
  #open link in new browser instance
  #sign petition as another user: victoriakfb??

  #----------
  #sign in to victorykit.com as admin
  #go to /admin/experiments

  #note:
  #spins count of 2 is due to current sub-optimal implementation which spins on signing instead of sharing

  #check spins against petition #{id} facebook title: 2
  #check wins against petition #{id} facebook title: 1

  #check spins against petition #{id} facebook image: 2
  #check wins against petition #{id} facebook image: 1

  #check wins against facebook sharing options: facebook_popup: 1

end