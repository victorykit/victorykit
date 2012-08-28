require 'smoke_spec_helper'
require 'facebook_spec_helper'
require 'nokogiri'
require 'member_hasher'

describe 'creating a facebook title experiment' do

  it 'awards a win against the facebook title when facebook user signs' do

    pending 'need to config FACEBOOK_APP_ID and FACEBOOK_SECRET for CI'

    petition = create_a_featured_petition({
      title: 'Multiple facebook titles!',
      description: 'You betcha',
      facebook_titles: ['FB Title A', 'FB Title B']
    })

    force_result({ 
      'facebook sharing options' => 'facebook_popup', 
      'after share view 2' => 'button_is_most_effective_tool',
      'display countdown to share' => 'false' 
    })

    fb_test_user = create_facebook_test_user

    go_to petition_path(petition)
    sign_petition
    expected_shared_link = expected_facebook_share_link petition, current_member
    share_petition_on_facebook fb_test_user, :share

    experiment = facebook_experiment_results_for petition
    experiment.spins.should eq 1
    experiment.wins.should eq 0
    
    delete_member_cookie
    go_to_facebook
    click_shared_link expected_shared_link
    sign_petition
    
    experiment = facebook_experiment_results_for petition
    experiment.spins.should eq 1
    experiment.wins.should eq 1
  end
  
end
