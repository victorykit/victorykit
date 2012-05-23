class DemandProgressGateway < ActiveRecord::Base
  self.abstract_class = true
  
  if Rails.env.development?
  	establish_connection :development
  elsif Rails.env.test?
  	establish_connection :test
  else 
  	establish_connection :demand_progress_production
  end

end
