require 'rails_rinku'

class ConvertPetitionsDescriptionToHtml < ActiveRecord::Migration
  include ActionView::Helpers

  def up
    petitions = Petition.find :all
    petitions.each do |petition|
      petition.description = Rinku.auto_link(simple_format(petition.description))
      petition.save
    end
  end

  def down
    petitions = Petition.find :all
    petitions.each do |petition|
      petition.description = sanitize(petition.description, :tags => %w(a), :attributes => %w(href))
      petition.save
    end
  end
end
