require 'capybara/rails'
require 'capybara/rspec'

def signin email, pass
  visit '/'
  click_link 'Sign Up or Log In'
  within '#new_user' do
    fill_in 'Email', with: email
    fill_in 'Password', with: pass
    fill_in 'Password confirmation', with: pass
    click_button 'Sign Up'
  end
  yield
  click_link 'Log Out'
end

def login email, pass
  visit '/'
  click_link 'Sign Up or Log In'
  within 'form[action="/sessions"]' do
    fill_in 'Email', with: email
    fill_in 'Password', with: pass
    click_button 'Log in'
  end
  yield
  click_link 'Log Out'
end

def sign petition, params=nil
  path = params ? 
  petition_path(petition, params) : 
  petition_path(petition)

  visit path
  fill_in 'First name', with: 'Peter'
  fill_in 'Last name', with: 'Griffin'
  fill_in 'Email', with: 'peter@gmail.com'
  click_button 'Sign!'
end

# for petition/new only with js on
def fill_in_description_with text
  page.execute_script(
    "$('#petition_description').data('wysihtml5')\
      .editor.composer.setValue('#{text}');")
end

def on_demand_email_path petition, member
  "/admin/on_demand_email/new?petition_id=#{petition.id}&member_id=#{member.id}"
end

def email_experiment_results_for petition
  visit '/admin/experiments?f=petitions'
  { spins: find('td.spins').text.to_i, 
    wins:  find('td.wins').text.to_i }
end
