class PetitionReportRepository

  # TODO: change datatable so sorting properties match database columns, eliminating the need for mapping
  PROPERTIES_MAP = {
    'petition_title'      => 'petition_title',
    'petition_created_at' => 'petition_created_at',
    'email_count'         => 'sent_emails_count',
    'open_rate'           => 'opened_emails_rate',
    'clicked_rate'        => 'clicked_emails_rate',
    'sign_rate'           => 'signed_from_emails_rate',
    'like_rate'           => 'like_rate',
    'hit_rate'            => 'hit_rate',
    'new_rate'            => 'new_members_rate',
    'unsub_rate'          => 'unsubscribes_rate'
  }

  def all_since_and_ordered(time_span, property, direction)
    direction = direction == :asc ? 'ASC NULLS FIRST' : 'DESC NULLS LAST'
    property  = PROPERTIES_MAP[property] || 'year'
    column    = property =~ /(count|rate)/ ? "#{property}_#{time_span}" : property

    PetitionReport.order("#{column} #{direction}").map do |report|
      PetitionReportPresenter.new(report, time_span)
    end
  end
end