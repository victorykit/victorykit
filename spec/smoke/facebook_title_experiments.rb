require 'smoke_spec_helper'
require 'nokogiri'
require 'member_hasher'

describe 'creating a facebook title experiment' do

  it 'awards a win against the facebook title when facebook user signs' do

    pending 'work in progress [martin/vini]'

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

    create_facebook_test_user
    
    go_to petition_path(petition)
    sign_petition
    share_petition_on_facebook
    
    experiment = facebook_experiment_results_for petition
    experiment.spins.should eq 1
    experiment.wins.should eq 0
    
    link_from_fb = facebook_referral_link petition, current_member
    delete_member_cookie
    
    go_to link_from_fb
    sign_petition
    
    experiment = facebook_experiment_results_for petition
    experiment.spins.should eq 1
    experiment.wins.should eq 1
  end

  def share_petition_on_facebook
    click(:id => 'the-one-in-the-modal')
    find_facebook_share_popup
  end
  
  def find_facebook_share_popup
    #type('victorkfb@gmail.com').into(:id => 'email')
    #home = $driver.current_window_handle;
    #$driver.window_handles
    # foreach (var window in _driver.WindowHandles)
    #  {
    #      if (_driver.SwitchTo().Window(window).Title.Contains("Search"))
    #      {
    #          _driver.SwitchTo().Frame("resultsFrame");
    #         PageHelper.Country.Click();
    #          break;
    #      }
    #  }
    # _driver.SwitchTo().Window(home);
  end
  
  def facebook_experiment_results_for petition
    as_admin do
      go_to 'admin/experiments?f=petitions'
      table = element(xpath: "//table[@id = 'petition #{petition.id} facebook title']")
      spins = table.find_element(xpath: "tbody/tr/td[@class='spins']").text.to_i
      wins = table.find_element(xpath: "tbody/tr/td[@class='wins']").text.to_i
      return OpenStruct.new(spins: spins, wins: wins)
    end
  end
  
  def facebook_referral_link petition, member
    "#{petition_path(petition)}?share_ref=#{member.to_hash}"
  end
end
