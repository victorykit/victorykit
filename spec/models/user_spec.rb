describe User do
  subject { build :user }

  it { should validate_presence_of :email }
  it_behaves_like 'email validator'

  it 'should not allow mass assignment of user roles by default' do
    expect { User.new(is_super_user: true, is_admin: true) }.
    to raise_error ActiveModel::MassAssignmentSecurity::Error
  end

  describe 'update' do
    subject { build :user }

    it 'should not allow mass assignment of user roles by default' do
      expect {subject.update_attributes({:is_super_user => true, :is_admin => true})}.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end

    it 'should allow mass assignment of user roles to admins' do
      subject.update_attributes({:is_super_user => true, :is_admin => true}, {:as => :admin} ).should be_true
    end
  end

  describe '#remove_password_digest_errors' do

    context 'when there is a password error' do
      before do
        subject.errors.add :password
        subject.remove_encrypted_password_errors
      end
      its(:errors) { should_not include :encrypted_password }
    end

    context 'when there is no password error' do
      before { subject.remove_encrypted_password_errors }
      its(:errors) { should be_empty }
    end
  end

end
