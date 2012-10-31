describe TimeBandedExperiment do

  before(:each) do
    @its = TimeBandedExperiment.new("some experiment", [Time.new(2012, 10, 20), Time.new(2012, 10, 22, 10, 30)])
  end

  it "should use default name when no date given" do
    @its.name_as_of(nil).should eq "some experiment"
  end

  it "should use default name prior to first transition" do
    @its.name_as_of(Time.new(2012, 10, 19)).should eq "some experiment"
  end

  it "should use name dated with transition at transition" do
    @its.name_as_of(Time.new(2012, 10, 20)).should eq "some experiment (reset 2012-10-20 00:00)"
    @its.name_as_of(Time.new(2012, 10, 22, 10, 30)).should eq "some experiment (reset 2012-10-22 10:30)"
  end

  it "should use name dated with closest earlier transition between transitions" do
    @its.name_as_of(Time.new(2012, 10, 20, 0, 1)).should eq "some experiment (reset 2012-10-20 00:00)"
    @its.name_as_of(Time.new(2012, 10, 21)).should eq "some experiment (reset 2012-10-20 00:00)"
    @its.name_as_of(Time.new(2012, 10, 22, 10, 29)).should eq "some experiment (reset 2012-10-20 00:00)"
  end

  it "should use name dated with last transition after last transition" do
    @its.name_as_of(Time.new(2012, 10, 22, 10, 31)).should eq "some experiment (reset 2012-10-22 10:30)"
  end

end