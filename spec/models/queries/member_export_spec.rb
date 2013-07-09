require 'spec_helper'

describe Queries::MembersExport do
  subject { Queries::MembersExport.new }

  it "should have generate some SQL" do
    subject.sql.should start_with("SELECT")
  end

  context "stubbed sql" do
    before(:each) do
      subject.stub(:sql).and_return("SELECT * FROM members WHERE 1 = 1")
      subject.stub(:klass).and_return(Member)
    end

    it "should append a limit and offset" do
      subject.sql_for_batch(100, 20).should == "SELECT * FROM members WHERE 1 = 1 AND members.id > 20 ORDER BY members.id LIMIT 100"
    end

    it "should return back the total count of rows" do
      subject.total_rows.should == 0
    end
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


