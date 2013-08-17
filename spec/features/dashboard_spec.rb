describe 'dashboard' do

  context 'an admin' do
    let(:user) { create :admin_user }

    it 'should see stats for a petition', js: true, driver: :webkit do
      pending "This isn't linked directly in the dashboard and doesn't appear to render when statsd isn't available. Fix in a separate commit."
      login user.email, user.password do
        visit '/admin/petitions'
        sleep 60
        wait_until do
          not find('tbody').text.empty?
        end
      end
    end
  end
end
