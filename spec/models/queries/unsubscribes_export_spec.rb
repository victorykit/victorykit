require 'spec_helper'

describe Queries::UnsubscribesExport do
  subject { Queries::UnsubscribesExport.new(from: 1.year.ago, to: 1.year.from_now) }

  it "should have generate some SQL" do
    subject.sql.should start_with("SELECT")
  end

  context "with objects" do
    let!(:unsubscribe) { FactoryGirl.create(:unsubscribe) }

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

        specify{ header.should include("email") }
        specify{ header.should include("first_name")}
        specify{ header.should include("last_name")}
        specify{ header.should include("created_at")}
      end

      describe "first row" do
        let(:first_row) { @parsed[1] }

        specify{ first_row.should include(unsubscribe.email.to_s) }
        specify{ first_row.should include(unsubscribe.member.first_name.to_s)}
        specify{ first_row.should include(unsubscribe.member.last_name.to_s)}
      end
    end
  end
end


