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
def set_default_experiment_results
  force_result({
    "signature display threshold" => 0,
    "show thermometer" => 'true',
    "seed signatures with petition creator" => "false"})

    #full (I think) list of experiments that affect layout:
    #
    #"petition side" => "petitionleft",
    #"thermometer and social icon placement" => "therm1",
    #"change button color for sign petition" => "buttoncolor1",
    #"change containing box color for sign petition" => "signaturecolor1",
    #"change thermometer color" => "redthermometer",
    #"change positioning and visibility of labels on sign petition form" => "signature_labels_beside_inputs_no_asterisk",
    #"test different messaging on progress bar" => "x_signatures_of_y",
    #"testing different widths" => "fullwidthpetition",
    #"different background for thank you box" => "hex_f5f5f5",
    #"different arrow colors in thank you box" => "bluearrow",
    #"full name vs first and last name" => "fullname",
    #"facebook_nps" => "facebook_like",
    #"sign button" => 'Sign!',
    #"include Facebook on share" => 'true',
    #"signature display threshold" => 0,
    #"show thermometer" => 'true',
    #"seed signatures with petition creator" => "false",
    #"toggle showing vs. not showing modal" => 'false',
    #"change layouts" => "bootstrap",
end

def force_result(params)
  go_to "whiplash_sessions"
  params.each do |k, v|
    type(v).into(name: k)
  end
  click name: "commit"
end