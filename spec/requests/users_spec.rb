describe 'a user' do
  let(:email) { 'user@test.com' }
  let(:pass)  { 'pass' }

  context 'joining the site' do

    it 'should successfuly sign in' do
      signin email, pass do
        page.current_path.should eq '/'
        page.should have_content 'Log Out'
      end  
    end

  end

  context 'already registered' do
    before { create(:user, email: email, password: pass) }
    
    it 'should successfuly login' do
      login email, pass do
        page.current_path.should eq '/'
        page.should have_content 'Log Out'
       end 
    end

  end

end