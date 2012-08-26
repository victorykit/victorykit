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
  logout
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
  logout
end

def logout
  click_link 'Log Out'
end


