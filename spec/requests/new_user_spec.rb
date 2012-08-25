require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'

describe 'a new user' do
  
  it 'should be able to create an account' do
    visit '/login'

    within '#new_user' do
      fill_in 'Email', with: 'zombie@gmail.com'
      fill_in 'Password', with: 'turtles'
      fill_in 'Password confirmation', with: 'turtles'
      click_button 'Sign Up'
    end
    
    page.should have_content 'Log Out'
  end

end