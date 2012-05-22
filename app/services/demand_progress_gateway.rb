class DemandProgressGateway < ActiveRecord::Base
  self.abstract_class = true
  
  establish_connection "demand_progress_#{Rails.env}"
end
