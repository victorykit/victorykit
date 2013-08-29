shared_examples_for "a login protected page" do
  it "allows valid users to carry out the action" do
    @user = create(:user)
    sign_in @user
    action
    should_not redirect_to login_path
  end
  it "disallows non logged in users to carry out the action" do
    action
    should redirect_to login_path
  end
end

shared_examples_for "an admin only resource page" do
  it "allows valid users to carry out the action" do
    @user = create(:admin_user)
    sign_in @user
    action
    should_not redirect_to login_path
  end
  it "disallows non admin users to carry out the action" do
    @user = create(:user)
    sign_in @user
    action
    should_not redirect_to login_path
    response.status.should == 403
  end
  it "disallows non logged in users to carry out the action" do
    action
    should redirect_to login_path
  end
end

shared_examples_for "a user with edit permissions resource page" do
  it "allows valid users to carry out the action" do
    @user = create(:user)
    sign_in @user
    action
    should_not redirect_to login_path
  end
  it "disallows users who did not create the petition to carry out the action" do
    @user = create(:user)
    sign_in @user
    action
    response.status.should == 403
  end
  it "disallows non super users and non admins to carry out the action" do
    @user = create(:user)
    sign_in @user
    action
    response.status.should == 403
  end
  it "disallows non logged in users to carry out the action" do
     action
     should redirect_to login_path
   end
end

shared_examples_for "email validator" do
  before(:each) do
    subject.email = email
    subject.valid?
  end

  context 'with no domain' do
    let(:email) { "asdsf" }
    specify { expect(subject).to have(1).error_on :email }
  end

  context 'with a localhost domain' do
    let(:email) { 'asdsf@localhost' }
    specify { expect(subject).to have(1).error_on :email }
  end

  context 'properly formatted' do
    let(:email) { 'asdsf@dfdf.net' }
    specify { expect(subject).to have(0).errors_on :email }
  end
end

shared_examples_for "a super-user only resource page" do
  it "allows super users to carry out the action" do
    @user = create(:super_user)
    sign_in @user
    action
    response.status.should_not == 403
    should_not redirect_to login_path
  end
  it "disallows non super users to carry out the action" do
    @user = create(:user)
    sign_in @user
    action
    response.status.should == 403
  end
  it "disallows non logged in users to carry out the action" do
    action
    should redirect_to login_path
  end
end

shared_examples_for "a hasher" do
  it "should validate a hash" do
    number = 100
    hashed_number = described_class.generate(number)
    described_class.validate(hashed_number).should == number
  end

  it "should return nil if trying to generate from nil or empty string" do
    described_class.generate(nil).should be nil
    described_class.generate("").should be nil
  end

  it "should return false after running validate for invalid hash" do
    described_class.validate('fake_hashed_number').should be_false
  end

  it "should return false after running validate for nil" do
    described_class.validate(nil).should be_false
  end
end
