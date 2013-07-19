require 'spec_helper'

describe Queries::MembersExport do
  subject { Queries::MembersExport.new }

  it "should have generate some SQL" do
    subject.sql.should start_with("SELECT")
  end

  context "with objects" do
    let!(:member) { FactoryGirl.create(:member) }

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

        specify{ header.should include("id") }
        specify{ header.should include("email")}
      end

      describe "first row" do
        let(:first_row) { @parsed[1] }

        specify{ first_row.should include(member.id.to_s) }
        specify{ first_row.should include(member.email)}
      end
    end
  end
end


