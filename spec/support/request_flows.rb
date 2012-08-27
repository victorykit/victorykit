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

def sign petition
  visit petition_path petition
  fill_in 'First name', with: 'Peter'
  fill_in 'Last name', with: 'Griffin'
  fill_in 'Email', with: 'peter@gmail.com'
  click_button 'Sign!'
end