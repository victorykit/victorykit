class DemandProgressGateway < ActiveRecord::Base
  self.abstract_class = true
  
  establish_connection(Settings.demand_progress.db_uri)
end