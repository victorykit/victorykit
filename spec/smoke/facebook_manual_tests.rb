require 'smoke_spec_helper'

describe "share on facebook using facebook_popup" do
  before do
    pending "manual steps until automation is figured out"
  end

  #assumptions:
  #test against testserver (will not work in all cases on localhost, e.g. where fb uses callbacks)
  #fb account for victorkfb

  #----------
  #sign in to victorykit as admin
  #create a petition: i like turtles
  
  #note: we need more than one of the spinnable options, otherwise they aren't tracked as experiments

  #click 'Customize Facebook Title'  
  #enter an alternate title: turtles are awesome
  #enter an alternate title: turtles are really awesome
  
  #click 'Customize Facebook Description'  
  #enter an alternate description: because they have shells
  #enter an alternate description: because they have nice shells

  #click 'Image Link'
  #enter an image url: www.maniacworld.com/i-lik-turtles.jpg
  #enter an image url: http://i3.kym-cdn.com/photos/images/original/000/181/192/tumblr_ls86k4MTEo1qgs1ido1_400.gif

  #click 'Create Petition' button
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

  #check spins against petition #{id} facebook title: 0
  #check wins against petition #{id} facebook title: 0

  #----------
  #go to facebook (logged in as victorkfb)
  #verify that petition title is alternate title: turtles are awesome
  #verify that petition image is alternate image: www.maniacworld.com/i-lik-turtles.jpg
  #verify that petition description is alternate description: because they have shells

  #----------
  #sign in to victorykit.com as admin
  #go to /admin/experiments

  #check spins against petition #{id} facebook title: 1
  #check wins against petition #{id} facebook title: 0
  #check wins against facebook sharing options: facebook_popup: 0

  #----------
  #copy petition link from facebook entry
  #open link in new browser instance
  #sign petition as another user: victoriakfb??

  #check wins against facebook sharing options: facebook_popup: 1
  #check spins against petition #{id} facebook title: 1
  #check wins against petition #{id} facebook title: 1

end