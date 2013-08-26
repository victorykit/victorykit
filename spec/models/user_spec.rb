describe User do
  subject { build :user }

  it { should validate_presence_of :email }
  it { should validate_presence_of :password}
  it { should validate_presence_of :password_confirmation}
  it { should_not validate_presence_of :current_password}
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

  describe 'change password' do
    let(:old_pass) { subject.password }

    before do
      subject.save # feel sad about it
      User.stub(:find).and_return subject
    end

    it 'should validate presence of password and confirmation if neither are set on update' do
      subject.password = nil
      subject.password_confirmation = nil
      subject.should_not be_valid
    end

    it 'should validate the old password if the user is changing her password' do
      subject.password = 'banana123'
      subject.password_confirmation = 'banana123'
      subject.current_password = old_pass + 'cupcake'
      subject.should_not be_valid(:update)
    end

    it 'should let the user change her password if she correctly gives the old password' do
      subject.password = 'banana123'
      subject.password_confirmation = 'banana123'
      subject.current_password = old_pass
      subject.should be_valid(:update)
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
