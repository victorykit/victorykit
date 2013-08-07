class ExtendCharacterLimitForSocialMediaTrials < ActiveRecord::Migration
  def change
    change_column :social_media_trials, :choice, :text
  end
end
