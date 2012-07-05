class PetitionTitlesValidator < ActiveModel::Validator
  def validate(record)
    validate_unique_by_title_type(record)
  end

  def validate_unique_by_title_type(record)
    PetitionTitle.types.each do |type|
      alt_titles = record.petition_titles.select { |pt| pt.title_type == type }
      texts = alt_titles.map {|pt| pt.text}
      record.errors[:base] << "#{PetitionTitle.full_name(type)} must be unique" if texts.count != texts.uniq.count
    end
  end
end
