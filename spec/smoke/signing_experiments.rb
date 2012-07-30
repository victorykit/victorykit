require 'smoke_spec_helper.rb'

describe "signing petitions" do
  before(:all) do
    @petition = create_a_petition
    set_default_experiment_results
  end
  describe "showing the thermometer" do
    it "should be visible" do
      go_to petition_path(@petition)
      element_exists(class: "progress_bar").should be_true
    end

  end

  describe "signing the petition" do
    it "should show seperate fields for entering first and last names" do

      go_to petition_path(@petition)
      element_exists(id: "signature_name").should be_false
      element_exists(id: 'signature_first_name').should be_true
      element_exists(id: 'signature_last_name').should be_true
    end
  end

    #full (I think) list of experiments that affect layout:
    #
    #"facebook sharing options" => "facebook_like",
    #"signature display threshold" => 0,
    #"show thermometer" => 'true',
    #"seed signatures with petition creator" => "false",
    #"toggle showing vs. not showing modal" => 'false',
    #"change layouts" => "bootstrap",
end


