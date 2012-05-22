class DemandProgressGateway < ActiveRecord::Base
  self.abstract_class = true
  
  establish_connection({:adapter => Settings.demand_progress.adapter, :host => Settings.demand_progress.host, :username => Settings.demand_progress.username, :password => Settings.demand_progress.password, :database => Settings.demand_progress.database})
end