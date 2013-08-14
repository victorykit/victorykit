desc "One-time task: backfill memberships table."
task :backfill_memberships => :environment do
  Rails.logger.info "Updating memberships..."
  ActiveRecord::Base.connection.execute <<-SQL
    INSERT INTO memberships (member_id, last_emailed_at, last_signed_at, created_at, updated_at)
    SELECT
      members.id,
      MAX(sent_emails.created_at) AS last_emailed_at,
      MAX(sigs.created_at) AS last_signed_at,
      COALESCE(MAX(joins.created_at), members.created_at) AS created_at,
      CURRENT_TIMESTAMP AS updated_at
    FROM members
    INNER JOIN sent_emails         ON members.id = sent_emails.member_id
    INNER JOIN signatures AS sigs  ON members.id = sigs.member_id
    LEFT  JOIN signatures AS joins ON ( members.id = joins.member_id AND joins.created_member = 't' )
    WHERE members.id NOT IN (
      SELECT DISTINCT unsubscribes.member_id FROM unsubscribes
    )
    GROUP BY members.id
  SQL
  Rails.logger.info "Done updating memberships."
end
