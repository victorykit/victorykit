require 'spec_helper'

describe "petitions/edit" do
  before(:each) do
    @petition = assign(:petition, stub_model(Petition,
      :title => "MyString",
      :description => "MyText"
    ))
  end

  it "renders the edit petition form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => petitions_path(@petition), :method => "post" do
      assert_select "input#petition_title", :name => "petition[title]"
      assert_select "textarea#petition_description", :name => "petition[description]"
    end
  end
end
