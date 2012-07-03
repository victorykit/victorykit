class ChangeFacebookToFacebookLikeReferenceType < ActiveRecord::Migration
  def up
  	Signature.where(reference_type: 'facebook').each do |record|
      record.reference_type = "facebook_like"
      record.save!
    end	
  end

  def down
  	Signature.where(reference_type: 'facebook_like').each do |record|
      record.reference_type = "facebook"
      record.save!
    end	
  end
end
