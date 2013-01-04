describe 'dashboard' do
  
  context 'an admin' do
    let(:user) { create :admin_user }

    it 'should see stats for a petition', js: true, driver: :webkit do
      login user.email, user.password do
        visit '/admin/petitions'
        find('tbody').text.should_not be_empty
      end
    end

  end

end
