describe 'email experiments' do
  before(:all) { DatabaseCleaner.strategy = :truncation }

  describe 'multiple subjects experiment' do
    let(:email) { 'user@test.com' }
    let(:pass ) { 'pass' }
    before { create(:admin_user, email: email, password: pass) }

    it 'should win', :js => true do
      pending 'work in progress'
      login email, pass do
        visit new_petition_path
        fill_in 'Title', with: 'I like Turtles'
        fill_in 'petition_description', with: 'Turtles are awesome!'
        click_link 'Customize Email Subject'
        sleep 900

        #click_button 'Create Petition'
      end
    end

  end

end