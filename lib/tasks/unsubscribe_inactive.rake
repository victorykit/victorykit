task 'unsubscribe_inactive' => :environment do
  Member.active.where("members.id > #{ENV['UNSUBSCRIBE_FROM']}").order('members.id').find_each do |member|
    puts "Checking member with ID #{member.id}..." if member.id % 1000 == 0
    if member.signatures.where("created_at > '2012-09-01'").count == 0 && member.referrals.where("created_at > '2012-09-01'").count == 0
      puts "Unsubscribing #{member.id} with address #{member.email}"
      Unsubscribe.unsubscribe_member(member)
    end
  end
end
