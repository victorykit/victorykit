describe 'petitions' do
  let(:email) { 'user@test.com' }
  let(:pass)  { 'pass' }

  shared_examples 'an author' do

    it 'should successfully create a petition' do
      login email, pass do
        visit new_petition_path
        fill_in 'Title', with: 'I like Turtles'
        fill_in 'Short summary', with: 'I love them'
        fill_in 'Description', with: 'Turtles are awesome!'
        click_button 'Create Petition'

        page.current_path.should =~ /petitions\/\d+/
        page.should have_content 'Petition was successfully created.'
        page.should have_content 'I like Turtles'
        page.should have_content 'Turtles are awesome!'
      end  
    end
    
  end

  context 'a regular user' do
    before { create(:user, email: email, password: pass) }
    
    it_behaves_like 'an author'
    
    it 'cannot send preview emails to herself' do
      login email, pass do
        visit new_petition_path
        page.should_not have_content "Email a preview to #{email}"
      end
    end
  end

  context 'an admin user' do
    before { create(:admin_user, email: email, password: pass) }

    it_behaves_like 'an author'
    
    it 'can send a preview email to herself' do
      login email, pass do
        visit new_petition_path
        page.should have_content "Email a preview to #{email}"
      end
    end
  end

end

