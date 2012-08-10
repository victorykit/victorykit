require 'spec_helper'

describe UnsubscribesController do
  
  describe 'GET new' do

    shared_examples 'assigns @unsubscribe' do
      specify { assigns(:unsubscribe).should be_a_new(Unsubscribe) }
    end

    context 'without email hash' do
      before { get :new }      
      it_behaves_like 'assigns @unsubscribe'
    end
    
    context 'with email hash' do
      let(:sent_email) { create :sent_email }
      let(:email) { sent_email.email }
      let(:hash) { SentEmailHasher.generate(sent_email.id) }

      before { get :new, :n => hash }
 
      it_behaves_like 'assigns @unsubscribe'

      specify { assigns(:email_hash).should == hash }
      specify { assigns(:email).should == email }
    end
  end

  describe 'POST create' do   
    let(:member) {create :member}
    
    context 'with valid params' do
      before :each do
        Unsubscribe.any_instance.stub(:save).and_return(true)
        a = ''
        256.times{a << 'a'}
        request.env['HTTP_USER_AGENT'] = a
        post :create, unsubscribe: {email: member.email}
      end
      describe 'the newly created unsubscribe' do
        subject { assigns(:unsubscribe) } 
        it { should be_a(Unsubscribe) }
        its(:cause) { should == 'unsubscribed'}
        its(:ip_address) { should == '0.0.0.0'}
        a = ''
        255.times{a << 'a'}
        its(:user_agent) { should == a}
      end      
    end
    
    context 'with invalid params' do
      before :each do
        Unsubscribe.any_instance.stub(:save).and_return(false)
        post :create, unsubscribe: {email: member.email}
      end
      it 'assigns a newly created but unsaved unsubscribe as @unsubscribe' do
        assigns(:unsubscribe).should be_a_new(Unsubscribe)
      end
      it 'should redirect to new unsubscribe url' do
        response.should redirect_to new_unsubscribe_url
      end
    end

    context 'when member not found' do
      before :each do
        Member.any_instance.stub(:find_by_email).and_return(nil)
        post :create, unsubscribe: {email: 'does@not.exist'}
      end
      it 'should redirect to new unsubscribe url' do
        response.should redirect_to new_unsubscribe_url
      end
    end
    
    context 'referred from an email' do
      let(:sent_email) {create :sent_email, member: member}
      
      before :each do
        post :create, unsubscribe: { email: member.email }, email_hash: sent_email.to_hash
      end

      it 'associates the email with the unsubscribe' do
        unsubscribe = Unsubscribe.find_by_member_id member
        unsubscribe.sent_email.should == sent_email
      end
    end

    context 'when entering an email in a different case' do
      let(:member) {create :member, email: 'me@my.com'}
      it 'unsubscribes the member' do
        post :create, unsubscribe: {email: member.email.upcase}
        unsubscribe = Unsubscribe.find_by_member_id member
        unsubscribe.should_not be_nil
      end
    end
  end
end
