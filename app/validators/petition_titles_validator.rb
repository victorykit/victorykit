class PetitionTitlesValidator < ActiveModel::Validator
  def validate(record)
    validate_unique_by_title_type(record)
  end

  def validate_unique_by_title_type(record)
    PetitionTitle.title_types.each do |type|
      alt_titles = record.petition_titles.select { |pt| pt.title_type == type }
      texts = alt_titles.map {|pt| pt.text}
      record.errors[:petition_titles] << "must be unique, but #{type} has duplicates." if texts.count != texts.uniq.count
    end
  end
end
