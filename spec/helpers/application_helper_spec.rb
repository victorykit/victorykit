describe ApplicationHelper do

  describe 'float_to_percentage' do
    it 'should format as percent rounded to two decimals' do
      float_to_percentage(0.35256).should == "35.26%"
    end
  end  

  describe 'format_date_time' do
    it 'should format as YYYY-mm-dd hh:mm' do      
      format_date_time(Time.utc(2007, 2, 10, 20, 30, 45)).should == "2007-02-10 20:30"
    end
  end
end