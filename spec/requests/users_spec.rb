describe 'a user' do
  let(:email) { 'user@test.com' }
  let(:pass)  { 'pass' }

  context 'visiting the home page' do
    before { visit '/' }
    
    subject { page }
    
    it { should have_content 'Win your campaign for change' }
    it { should have_link 'Click here to start a petition' }
  end

  context 'joining the site' do

    it 'should successfuly sign in' do
      signin email, pass do
        page.current_path.should eq '/'
        page.should have_link 'Log Out'
      end  
    end
  end

  context 'already registered' do
    before { create(:user, email: email, password: pass) }
    
    it 'should successfuly login' do
      login email, pass do
        page.current_path.should eq '/'
        page.should have_link 'Log Out'
       end 
    end
  end

  context 'visiting the privacy policy page' do
    before { visit '/privacy' }

    subject { page }

    it { should have_content 'Privacy Policy' }
    it { should have_content "We don't share your email address without your permission." }
  end

end