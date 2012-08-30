require 'support/request_facebook_flows'
require 'whiplash'

class Foo
  include Bandit
end

describe 'facebook sharing experiments' do

  pending 'convert to capybara; also stabilize (if sporadic failures still occurring)'

  let(:admin) { create :admin_user }

  # facebook_popup
  it 'registers wins when facebook_popup shared link yields signature' , js: true, driver: :webkit do

    pending 'convert to capybara; also stabilize (if sporadic failures still occurring)'

    login admin.email, admin.password do
      create_petition({
        title: 'Facebook share via popup',
        # description: "So much sharing",
        facebook_titles: ['FB Title A', 'FB Title B'],
        images: ['placekitten.com/g/200/200','placekitten.com/g/200/220']
      })
    end
    
    f = Foo.new
    sesh = {:session_id => "who cares"}
    f.spin_for_choice 'facebook sharing options', ['facebook_popup'], sesh
    f.spin_for_choice 'after share view 2', ['button_is_most_effective_tool'], sesh
    f.spin_for_choice 'display countdown to share', ['false'], sesh

    begin
      fb_victor = create_facebook_test_user

      sign petition
      share_petition_on_facebook fb_victor, :share

      #need to capture the expected link before clearing the current_member cookie
      expected_shared_link = "#{petition_path(petition)}?share_ref=#{current_member.to_hash}"
      delete_member_cookie

      as_admin_at_petition_experiments do
        assert_petition_experiment_results "petition #{petition.id} facebook title", 1, 0
        assert_petition_experiment_results "petition #{petition.id} facebook image", 1, 0
      end

      # cheat: going back to fb as fb_victor to save time creating another user and logging in again
      visit_facebook
      click_shared_link expected_shared_link
      sign_at_petition

      as_admin_at_petition_experiments do
        assert_petition_experiment_results "petition #{petition.id} facebook title", 1, 1
        assert_petition_experiment_results "petition #{petition.id} facebook image", 1, 1
      end
    ensure
      #todo: better to use something self-scoping like a yield block, but need access to fb_victor in block, so...
      # delete_fb_test_user fb_victor
    end
  end

  #facebook_request
  it 'registers wins when facebook_request shared link yields signature' do

    pending 'convert to capybara; also stabilize (if sporadic failures still occurring)'

    petition = create_a_featured_petition({
      title: 'Multiple facebook titles!',
      description: 'You betcha',
      facebook_titles: ['FB Title A', 'FB Title B'],
      images: ['placekitten.com/g/200/200','placekitten.com/g/200/220']
    })

    force_result({
      'facebook sharing options' => 'facebook_request',
      'after share view 2' => 'button_is_most_effective_tool',
      'display countdown to share' => 'false'
    })

    begin
      fb_victor = create_facebook_test_user "victor"
      fb_vincent = create_facebook_test_user "vincent", false
      facebook_friend fb_victor, fb_vincent

      visit petition_path(petition)
      sign_petition
      expected_shared_link = "#{petition_path(petition)}?share_ref=#{current_member.to_hash}"
      share_petition_on_facebook fb_victor, :request

      as_admin_at_petition_experiments do
        assert_petition_experiment_results "petition #{petition.id} facebook title", 1, 0
        assert_petition_experiment_results "petition #{petition.id} facebook image", 1, 0
      end

      delete_member_cookie
      login_at_facebook fb_vincent
      visit_facebook "/notifications"
      click_request_link

      switch_to_frame(:class => "smart_sizing_iframe")
      element(class: "mobile_signup_button").click
      sign_petition "Vincent", "leTest", fb_vincent["email"]

      as_admin_at_petition_experiments do
        assert_petition_experiment_results "petition #{petition.id} facebook title", 2, 1
        assert_petition_experiment_results "petition #{petition.id} facebook image", 2, 1
      end
    ensure
      delete_fb_test_user fb_victor
      delete_fb_test_user fb_vincent
    end
  end
  
  # facebook_wall
  it 'registers win for facebook_wall' do
    pending 'implement test'
  end
end

#todo: temporary while sorting out fb testing and cleanup
describe 'delete all fb test users' do
  pending 'run manually when needed'
  #delete_all_fb_test_users
end