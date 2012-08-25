require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'

describe 'a user' do
  let(:email) { 'zombie@gmail.com' }
  let(:pass)  { 'turtles' }

  context 'joining the site' do

    it 'should sign in' do
      visit '/'
      click_link 'Sign Up or Log In'
      
      within '#new_user' do
        fill_in 'Email', with: email
        fill_in 'Password', with: pass
        fill_in 'Password confirmation', with: pass
        click_button 'Sign Up'
      end

      page.current_path.should eq '/'
      page.should have_content 'Log Out'
    end

  end

  context 'already registered' do

    before do 
      [Petition, User].map(&:delete_all)
      create(:user, email: email, password: pass)
    end
    
    it 'should login' do
      visit '/'
      click_link 'Sign Up or Log In'
      
      within 'form[action="/sessions"]' do
        fill_in 'Email', with: email
        fill_in 'Password', with: pass
        click_button 'Log in'
      end

      page.current_path.should eq '/'
      page.should have_content 'Log Out'
    end

  end

end