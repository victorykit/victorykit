require 'support/request_facebook_flows'

describe 'facebook sharing experiments' do

  # before(:all) do
  #   config_for_integration self
  # end

  # after(:all) do
  #   reset_config
  # end

  let(:admin) { create :admin_user }

  context 'when sharing via facebook_popup' do
    it 'awards wins when shared link leads to signature', js: true, driver: :selenium do

      pending "fix config issues"

      login admin.email, admin.password do
        create_petition({
          title: 'Facebook share via popup',
          fb_titles: ['FB Title A', 'FB Title B'],
          images: ['http://placekitten.com/g/200/200','http://placekitten.com/g/200/220']
        })
      end
      petition = Petition.last

      force_result({'facebook sharing options' => 'facebook_popup'})

      begin
        fb_victor = create_facebook_test_user

        sign petition
        share_petition fb_victor, :share
        #need to capture the expected link before clearing the current_member cookie
        expected_shared_link = "#{petition_path(petition)}?share_ref=#{current_member.to_hash}"
        click_sign_again

        visit_petition_experiments admin do
          assert_petition_experiment_results "petition #{petition.id} facebook title", 1, 0
          assert_petition_experiment_results "petition #{petition.id} facebook image", 1, 0
        end

        # cheat: going back to fb as fb_victor to save time creating another user and logging in again
        visit_facebook
        click_shared_link expected_shared_link do
          sign_at_petition
        end

        visit_petition_experiments admin do
          assert_petition_experiment_results "petition #{petition.id} facebook title", 1, 1
          assert_petition_experiment_results "petition #{petition.id} facebook image", 1, 1
        end

      ensure
        delete_fb_test_user fb_victor
      end
    end
  end

  context 'when sharing via facebook_request' do
    it 'facebook_request registers wins when shared link leads to signature', js: true, driver: :selenium do

      pending 'handle/simulate fb request loading app for localhost'

      login admin.email, admin.password do
        petition = create_petition({
          title: 'Multiple facebook titles!',
          description: 'You betcha',
          fb_titles: ['FB Title A', 'FB Title B'],
          images: ['http://placekitten.com/g/200/200','http://placekitten.com/g/200/220']
        })
      end
      petition = Petition.last

      force_result({'facebook sharing options' => 'facebook_request'})

      begin
        fb_victor = create_facebook_test_user "victor"
        fb_vincent = create_facebook_test_user "vincent", false
        facebook_friend fb_victor, fb_vincent

        sign petition
        share_petition fb_victor, :request
        click_sign_again

        visit_petition_experiments admin do
          assert_petition_experiment_results "petition #{petition.id} facebook title", 1, 0
          assert_petition_experiment_results "petition #{petition.id} facebook image", 1, 0
        end

        login_at_facebook fb_vincent
        visit_facebook "/notifications"
        click_request_link

        within_frame 1 do
          find(:class, "mobile_signup_button").click
          sign_at_petition "Vincent", "leTest", fb_vincent["email"]
        end

        visit_petition_experiments admin do
          assert_petition_experiment_results "petition #{petition.id} facebook title", 2, 1
          assert_petition_experiment_results "petition #{petition.id} facebook image", 2, 1
        end

      ensure
        delete_fb_test_user fb_victor
        delete_fb_test_user fb_vincent
      end
    end
  end

end
