class MemberPetitionsObserver < ActiveRecord::Observer
  observe :signature, :scheduled_email

  def after_create(record)
    unless record.member.previous_petition_ids.include? record.petition.id.to_s
      record.member.add_petition_id(record.petition.id)
    end
  end
end