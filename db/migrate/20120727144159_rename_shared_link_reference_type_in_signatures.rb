class RenameSharedLinkReferenceTypeInSignatures < ActiveRecord::Migration
  def up
    Signature.find_all_by_reference_type("shared_link").each do |el|
      el.reference_type = "forwarded_notification"
      el.save!
    end
  end

  def down
    Signature.find_all_by_reference_type("forwarded_notification").each do |el|
      el.reference_type = "shared_link"
      el.save!
    end
  end
end
