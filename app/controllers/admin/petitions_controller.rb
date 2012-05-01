class Admin::PetitionsController < ApplicationController
  def index
    @petitions = Petition.all
    @analytics = Analytics.new(AnalyticsGateway.get_report_results)
  end

  class Analytics
    include Rails.application.routes.url_helpers

    def initialize(data)
      @data = data
    end

    def [](petition)
      hits = @data.find { |k,v| k == petition_path(petition) }[1].pageviews.to_i    
      signatures = petition.signatures.count
      new_members = petition.signatures.count(conditions: "created_member is true")
      
      {
        :hits => hits,
        :signatures => signatures,
        :conversion => (signatures.to_f / hits.to_f),
        :new_members => new_members,
        :virality => (new_members.to_f / signatures.to_f)
      }
    end
  end

end
