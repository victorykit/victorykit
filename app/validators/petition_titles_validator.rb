class PetitionTitlesValidator < ActiveModel::Validator

  def validate(record)
    validate_unique_by_title_type(record)
  end

  def validate_unique_by_title_type(record)
    PetitionTitle.types.each do |type|
      alt_titles = record.petition_titles.select { |pt| pt.title_type == type }
      titles = alt_titles.map {|pt| pt.title}
      record.errors[:base] << "#{PetitionTitle.full_name(type)} must be unique" if titles.count != titles.uniq.count
    end
  end
end
