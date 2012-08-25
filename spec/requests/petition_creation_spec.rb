require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'

describe 'petition creation' do
  
  context 'an existing user' do
    let(:email) { 'zombie@gmail.com' }
    let(:pass)  { 'turtles' }

    before { create(:user, email: email, password: pass) }
    after  { [Petition, User].map(&:delete_all) }

    it 'should successfuly create a new petition' do
      # login
      visit '/login'
      within('form[action="/sessions"]') do
        fill_in 'Email', with: email
        fill_in 'Password', with: pass
        click_button 'Log in'
      end

      # create
      visit '/petitions/new'
      fill_in 'Title', with: 'I like Turtles'
      fill_in 'Short summary', with: 'I love them'
      fill_in 'Description', with: 'Turtles are awesome!'
      click_button 'Create Petition'

      page.should have_content 'Petition was successfully created.'
      
      click_link 'Log Out'
    end
  end

end