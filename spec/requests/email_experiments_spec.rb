describe 'email experiments' do

  describe 'multiple subjects experiment' do
    let(:member) { create :member }
    let(:user  ) { create :admin_user }

    #FIXME: split in multiple examples, like:
    # - should allow multiple subjects
    # - should send email with the hashed link
    # - should compute win after signin

    it 'should win after signature from email', :js => true, :driver => :webkit do
      login user.email, user.password do
        create_petition(subjects: ['tutles 1', 'tutles 2'])
        
        petition = Petition.last
        
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