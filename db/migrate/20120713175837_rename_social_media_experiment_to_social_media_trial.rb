class RenameSocialMediaExperimentToSocialMediaTrial < ActiveRecord::Migration
  def change
    rename_table :social_media_experiments, :social_media_trials
  end
end
