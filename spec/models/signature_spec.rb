require 'spec_helper'

describe Signature do
  
  context 'validating' do
    it { should validate_presence_of :email }
    it { should validate_presence_of :name }
    it_behaves_like 'email validator'

    context 'reference types' do      

      ['facebook_like', 'facebook_popup', 'facebook_wall_widget', 'email', 'twitter'].each do |type|
        context "when #{type}" do
          subject { build(:signature, reference_type: type) }
          it { should be_valid }
        end
      end
      
      context 'when unkown' do
        subject { build(:signature, reference_type: 'unkown') }
        it { should_not be_valid }
      end
    end
  end

  context 'given a really long user agent' do
    subject { build(:signature, user_agent: '0' * 512) }
    before { subject.save! }
    its(:user_agent) { should have(255).characters }
  end

end
