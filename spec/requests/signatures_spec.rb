describe 'signatures' do
  let(:id) { create(:petition).id }

  context 'a user' do
    let(:hash) { Signature.last.member.to_hash }

    it 'should sign a petition' do
      sign_petition id
      page.should have_content 'Thanks for signing!'
      page.current_url.should include "l=#{hash}"
    end

    it 'should provide his info' do
      visit "/petitions/#{id}"
      click_button 'Sign!'

      page.should_not have_content 'Thanks for signing!'

      errors = all('.signature-form#non-mobile .alert-error', text: "can't be blank")
      errors.should have(3).elements
    end
  end

  context 'someone else' do
    it 'should be able to sign' do
      pending 'work in progress'
      sign_petition id
      click_link 'sign-again-link'
    end
  end

end