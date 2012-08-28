require 'smoke_spec_helper'
require 'facebook_spec_helper'

describe 'creating a facebook title experiment' do

  it 'awards a win against the facebook title when facebook user signs' do

    petition = create_a_featured_petition({
      title: 'Multiple facebook titles!',
      description: 'You betcha',
      facebook_titles: ['FB Title A', 'FB Title B'],
      images: ['placekitten.com/g/200/200','placekitten.com/g/200/220']
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

    at_petition_experiments do
      assert_petition_experiment_results "petition #{petition.id} facebook title", 1, 0
      assert_petition_experiment_results "petition #{petition.id} facebook image", 1, 0
    end
    
    delete_member_cookie
    go_to_facebook
    click_shared_link expected_shared_link
    sign_petition

    at_petition_experiments do
      assert_petition_experiment_results "petition #{petition.id} facebook title", 1, 1
      assert_petition_experiment_results "petition #{petition.id} facebook image", 1, 1
    end
  end
  
end
