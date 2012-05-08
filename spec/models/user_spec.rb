require 'spec_helper'

describe User do
  describe "validation" do
    describe "create" do
      subject { build(:user) }
      it { should validate_presence_of :email }
      it { should validate_presence_of :password}
      it { should validate_presence_of :password_confirmation}
      it { should_not validate_presence_of :old_password}
      it "should not allow mass assignment of user roles by default" do
        expect {User.new({:is_super_user => true, :is_admin => true})}.to raise_error ActiveModel::MassAssignmentSecurity::Error
      end
      it "should not validate password digest if password validation fails" do
        u = User.new
        u.save
        u.errors.should_not include :password_digest
      end
    end
    describe "update" do
      subject { create(:user) }
      it "should not allow mass assignment of user roles by default" do
        expect {subject.update_attributes({:is_super_user => true, :is_admin => true})}.to raise_error ActiveModel::MassAssignmentSecurity::Error
      end
      it "should allow mass assignment of user roles to admins" do
        subject.update_attributes({:is_super_user => true, :is_admin => true}, {:as => :admin} ).should be_true
      end
    end
    describe "change_password" do
      let(:old_password) { "MY_OLD_SECRET_PASSWORD1"}
      subject { create(:user, password: old_password) }
      it { should validate_presence_of :email }
      it "should not validate presence of password and confirmation if neither are set on update" do
        subject.password = nil
        subject.password_confirmation = nil
        subject.should be_valid
      end
      it "should validate the old password if the user is changing their password" do
        subject.password = "foo"
        subject.password_confirmation = "foo"
        subject.old_password = "probably_not_my_old_password"
        subject.should_not be_valid(:update)
      end
      it "should let the user change their password if they correctly give the old password" do
        subject.password = "foo"
        subject.password_confirmation = "foo"
        subject.old_password = old_password
        subject.should be_valid(:update), subject.errors.inspect
      end
    end
  end
end
