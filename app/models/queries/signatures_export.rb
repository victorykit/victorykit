module Queries
  class SignaturesExport < Export
    attr_accessor :petition_id

    def klass
      Signature
    end

    def sql
      Signature.where(petition_id: petition_id).select([:first_name, :last_name, :email, :city, :state_code, :country_code, :created_at]).to_sql
    end

    def name
      "signatures-#{petition_id}"
    end
  end
end