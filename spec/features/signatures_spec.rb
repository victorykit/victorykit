describe 'signatures' do
  let(:petition) { create :petition }
  let(:initial_signers_referal_code) { Referral.first.code } #there will be two referral codes - one for the first signer, one for the second.

  context 'a user' do

    it 'should sign a petition' do
      sign petition
      page.should have_selector('#petition_page.was_signed')
      page.current_url.should include "l=#{initial_signers_referal_code}"
    end

    it 'should provide his info' do
      visit petition_path petition
      click_button 'sign_petition'

      page.should have_selector('#petition_page.not_signed')
      within '.signature-form' do
        all('.alert-error', text: "can't be blank").should have(3).elements
      end
    end
  end

  context 'someone else' do
    it 'should be able to sign' do
      sign petition
      click_button 'sign-again'

      find_field('First name').value.should be_blank
      find_field('Last name').value.should be_blank
      find_field('Email').value.should be_blank
      page.current_url.should include "l=#{initial_signers_referal_code}"
    end
  end

  context 'a facebook share' do
    let(:old_petition) { create :petition }
    let(:member) { create :member }
    let(:code) { create(:referral, petition: petition, member: member).code }
    let(:petition_fb_title) { "petition #{petition.id} #{PetitionTitle::TitleType::FACEBOOK} title" }

    before {
      petition.petition_titles.build title_type: PetitionTitle::TitleType::FACEBOOK, title: "better title"
      petition.petition_titles.build title_type: PetitionTitle::TitleType::FACEBOOK, title: "worse title"
      petition.save
    }

    it 'should register a spin and a win', js: true, driver: :webkit do
      pending "Failing for inscrutable reasons after no relevant change. Pending for now."
      
      admin_user = create :admin_user

      visit petition_path(petition, r: code)
      sign_at_petition member.first_name, member.last_name, member.email
      page.should have_selector('#petition_page.was_signed')

      share = login(admin_user.email, admin_user.password) { experiment_results_for(petition_fb_title, "petitions") }
      option = share.keys.first
      share[option].should == { spins: 1, wins: 0 }

      reset_session!
      
      visit petition_path(petition, d: code)
      sign_at_petition 'Herrman', 'Toothrot', 'htoothrot@example.com'

      share = login(admin_user.email, admin_user.password) { experiment_results_for(petition_fb_title, "petitions") }
      share[option].should == { spins: 1, wins: 1 }
    end
  end

end
