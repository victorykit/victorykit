describe 'email experiments' do

  describe 'multiple subjects experiment' do
    let(:user) { create(:admin_user) }

    #FIXME: split in multiple examples, like:
    # - should allow multiple subjects
    # - should send email with the hashed link
    # - should compute win after signin

    it 'should win after signature from email', :js => true, :driver => :webkit do
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
        
        wait_until do
          page.has_content? 'Petition was successfully created'
        end
        
        petition = Petition.last
        member = create(:member)

        visit on_demand_email_path(petition, member)
        link = find_link('Please, click here to sign now!')[:href]
        hash = link.scan(/n=(.*)$/).join

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