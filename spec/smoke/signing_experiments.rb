require 'smoke_spec_helper.rb'

describe "showing the thermometer" do
  before(:all) do
    @petition = create_a_petition
  end
  it "should be visible" do
    force_experiment_result("show thermometer", true)
    force_experiment_result("signature display threshold", 0)
    go_to petition_path(@petition)
    element_exists(class: "progress_bar").should be_true
  end

  it "should not be visible" do
    force_experiment_result("show thermometer", false)
    force_experiment_result("signature display threshold", 0)
    go_to petition_path(@petition)
    element_exists(class: "progress_bar").should be_false
  end

  def force_experiment_result(name, value)
    go_to "whiplash_sessions"
    type(value).into(name: name)
    click name: "commit"
  end
end