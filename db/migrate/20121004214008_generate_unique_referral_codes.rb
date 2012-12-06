class GenerateUniqueReferral < ActiveRecord::Migration
  def up
    old_code_regex = /^(\d+)\.(.*?)$/

    Referral.find_in_batches do |batch|
      batch.each do |c|
        if c.code =~ old_code_regex
          c.code = SecureRandom.urlsafe_base64(8)
          c.save(validate: false)
        end
      end
    end
  end

  def down
  end
end
