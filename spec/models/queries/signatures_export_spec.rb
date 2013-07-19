require 'spec_helper'

describe Queries::SignaturesExport do
  subject { Queries::SignaturesExport.new(petition_id: petition_id) }
  let(:petition_id)  { '1' }

  it "should have generate some SQL" do
    subject.sql.should start_with("SELECT")
  end

  context "with objects" do
    let(:petition)  { FactoryGirl.create(:petition) }
    let(:petition_id)  { petition.id }

    let!(:signature) { FactoryGirl.create(:signature, petition: petition) }

    before(:each) do
      @result = ""
      subject.as_csv_stream.each do |chunk|
        @result << chunk
      end
    end

    context "when parsed" do
      before(:each) do
        @parsed = CSV.parse(@result)
      end

      describe "header" do
        let(:header) { @parsed[0] }

        specify{ header.should include("email")}
      end

      describe "first row" do
        let(:first_row) { @parsed[1] }

        specify{ first_row.should include(signature.email)}
      end
    end
  end
end


