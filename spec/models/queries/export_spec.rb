require 'spec_helper'

describe Queries::Export do

  subject { Queries::Export.new }

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
end