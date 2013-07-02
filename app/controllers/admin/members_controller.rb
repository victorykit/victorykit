class Admin::MembersController < ApplicationController
  newrelic_ignore
  before_filter :require_admin

  def index
    respond_to do |format|
      format.html do
        @members = Member.active.
         paginate(:page => params[:page], :per_page => 50).
         order('created_at DESC')
      end

      format.csv do
        self.response.headers['Content-Type'] = 'text/csv'
        self.response.headers['Last-Modified'] = Time.now.ctime.to_s
        self.response.headers['Content-Disposition'] = 
          "attachment; active_members.csv"
        self.response_body = Enumerator.new do |y|
          i = 0
          Member.active.find_each do |member|
            y << member.csv_header.to_csv if i == 0
            y << member.csv_values.to_csv
            i += 1
            GC.start if i%500==0
          end
        end
      end
    end
  end
end
