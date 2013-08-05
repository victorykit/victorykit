class Admin::UnsubscribesController < ApplicationController
  before_filter :require_admin

  def index
    @unsubscribes = Unsubscribe.
        paginate(:page => params[:page], :per_page => 50).
        order('created_at DESC')
  end

  def new
  end

  def create

    if params[:file].present?
      upload    = params[:file].read.force_encoding('UTF-8')
      lines     = upload.split(/(\r)|(\n)/)
      filename  = params[:file].original_filename.parameterize
      timestamp = Time.now.to_i
      id        = "#{filename}#{timestamp}"
      batch_key = "unsubscribes.#{id}"

      REDIS.mset("#{batch_key}.members", 0, "#{batch_key}.unsubscribes", 0, "#{batch_key}.seen_lines", 0, "#{batch_key}.total_lines", lines.size)

      lines.each do |line|
        UnsubscribesWorker.perform_async(line, batch_key)
      end

      redirect_to admin_unsubscribe_path(id)
    end
  end

  def show
  end

  def stats
    key = params[:id]
    keys =  ['seen_lines', 'members', 'unsubscribes', 'total_lines'].map {|attr| "unsubscribes.#{key}.#{attr}"}

    seen_lines, members, unsubscribes, total_lines = REDIS.mget *keys

    render json: { total_lines: total_lines, seen_lines: seen_lines, members: members, unsubscribes: unsubscribes }
  end

  def export
    if (from = params[:from].try(:to_date)) && (to = params[:to].try(:to_date))
      respond_to do |format|
        format.csv {
          streaming_csv_export(Queries::UnsubscribesExport.new(from: from, to: to))
        }
      end
    end
  end
end
