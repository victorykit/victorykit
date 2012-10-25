class StripTrailingPeriodsFromSignatureAndMemberEmail < ActiveRecord::Migration
  def up
    Member.where("email like '%.'").each do |m|

      sanitized_email = m.email.chomp(".")

      #member email has uniqueness constraint
      if Member.where(email: sanitized_email).empty? then
        m.email = sanitized_email
        m.save!
      else
        if not Unsubscribe.find_by_member_id(m.id) then
          u = Unsubscribe.unsubscribe_member(m)
          u.cause = "duplicate/typo"
          u.save!
        end
      end

    end
  end

  def down
  end
end