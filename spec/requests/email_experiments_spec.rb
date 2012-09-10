describe 'email experiments' do

  describe 'multiple subjects experiment' do
    let(:member) { create :member }
    let(:user  ) { create :admin_user }

    it 'should win after signature from email', js: true, driver: :webkit do
      login user.email, user.password do
        # create two petitions
        petitions = 2.times.map do
          create_petition(subjects: ['tutles 1', 'tutles 2'])
        end

        # send emails for them
        hashes = petitions.reduce({}) do |result, petition|
          visit on_demand_email_path(petition, member)
          link = find('.sign-petition-link')[:href]
          hash = link.scan(/n=(.*)$/).join
          result[petition] = hash ; result
        end

        # check results
        petitions.each do |petition|
          results = email_experiment_results_for petition
          results[:spins].should eq 1
          results[:wins ].should eq 0
        end

        # sign and check again
        petitions.each do |petition|
          sign petition, { n: hashes[petition] }
          results = email_experiment_results_for petition
          results[:spins].should eq 1
          results[:wins ].should eq 1
        end
      end
    end
  end
end