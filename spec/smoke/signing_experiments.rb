require 'smoke_spec_helper.rb'

describe "signing petitions" do
  before(:all) do
    @petition = create_a_petition
    set_default_experiment_results
  end
  describe "showing the thermometer" do
    it "should be visible" do
      force_result("show thermometer" => 'true')
      go_to petition_path(@petition)
      element_exists(class: "progress_bar").should be_true
    end

    it "should not be visible" do
      force_result("show thermometer" => 'false')
      go_to petition_path(@petition)
      element_exists(class: "progress_bar").should be_false
    end
  end

  describe "signing the petition" do
    it "should show one field for entering a full name" do
      force_result("full name vs first and last name" => "fullname")

      go_to petition_path(@petition)
      element_exists(id: 'signature_name').should be_true
      element_exists(id: 'signature_first_name').should be_false
      element_exists(id: 'signature_last_name').should be_false
    end
    it "should show seperate fields for entering first and last names" do
      force_result("full name vs first and last name" => "firstandlastname")

      go_to petition_path(@petition)
      element_exists(id: "signature_name").should be_false
      element_exists(id: 'signature_first_name').should be_true
      element_exists(id: 'signature_last_name').should be_true
    end
  end

end


