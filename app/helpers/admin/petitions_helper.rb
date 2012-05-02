module Admin::PetitionsHelper
  
  def float_to_percentage(f)
    number_to_percentage(f*100, precision: 2)
  end
  
end