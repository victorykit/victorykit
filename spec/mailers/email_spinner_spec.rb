require "spec_helper"

describe EmailSpinner do
  let(:choices){["a", "b"]}
  let(:email){create :sent_email}
  let(:spinner){EmailSpinner.new} 

  it "gets a choice from bandit" do
    result = spinner.do_spin! email, "test_name", :test_goal, choices
    choices.should include result
  end

  it "saves experiment data for email" do
    spinner.do_spin! email, "test_name", :test_goal, choices

    experiment = email.email_experiments.first
    experiment.key.should == "test_name"
    experiment.goal.should == "test_goal"
    experiment.choice.should == choices.first
  end
end
