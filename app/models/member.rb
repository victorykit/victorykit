class Member < ActiveRecord::Base
  attr_accessible :name, :email
  
  def self.random_and_not_recently_contacted
    q = Member.connection.execute("SELECT members.id FROM members LEFT JOIN sent_emails ON (members.id = sent_emails.member_id AND sent_emails.created_at > now() - interval '1 week') LEFT JOIN unsubscribes ON (members.id = unsubscribes.member_id) WHERE sent_emails.member_id is null AND unsubscribes.member_id is null").to_a
    q.empty? ? nil : Member.find_by_id(q.sample['id'])
  end
end
