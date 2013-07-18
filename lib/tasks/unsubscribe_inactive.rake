task 'unsubscribe_inactive' => :environment do
  Member.active.where("members.created_at <= '2012-09-01'").find_each do |member|
    if member.signatures.where("created_at > '2012-09-01'").count == 0 && member.referrals.where("created_at > '2012-09-01'").count == 0
      Unsubscribe.unsubscribe_member(member)
    end
  end
end
