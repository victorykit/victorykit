describe 'email experiments' do
  before(:all) { DatabaseCleaner.strategy = :truncation }

  describe 'multiple subjects experiment' do
    let(:user) { create(:admin_user) }

    it 'should win', :js => true do
      login user.email, user.password do
        visit new_petition_path
        fill_in 'Title', with: 'I like Turtles'
        fill_in_description_with 'Turtles are awesome!'
        click_link 'Customize Email Subject'
        click_link 'Add Email Subject'
        within '#email_subjects' do
          all('input[type="text"]').each_with_index do |e, i|
            e.set "Customized #{i}"
          end   
        end
        click_button 'Create Petition'
        
        petition = Petition.last
        member = create(:member)

        visit on_demand_email_path(petition, member)
        click_link 'Please, click here to sign now!'
        hash = page.current_url.scan(/n=(.*)$/).join

        results = email_experiment_results_for petition
        results[:spins].should eq 1
        results[:wins ].should eq 0

        sign petition, { n: hash }

        results = email_experiment_results_for petition
        results[:spins].should eq 1
        results[:wins ].should eq 1
      end
    end

  end

end