describe 'signatures' do
  let(:petition) { create :petition }
  let(:hash) { Signature.last.member.to_hash }

  context 'a user' do
    it 'should sign a petition' do
      sign petition
      page.should have_selector '#thanksModal'
      page.current_url.should include "l=#{hash}"
    end

    it 'should provide his info' do
      visit petition_path petition
      click_button 'Sign!'

      page.should_not have_selector '#thanksModal'
      within '.signature-form#non-mobile' do
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
      page.current_url.should include "l=#{hash}"
    end
  end

end