module Queries
  class UnsubscribesExport < Export
    attr_accessor :from, :to

    def klass
      Unsubscribe
    end

    def sql
      Unsubscribe.between(from, to).select(['unsubscribes.email', 'members.first_name', 'members.last_name', 'unsubscribes.created_at']).joins(:member).to_sql
    end

    def name
      'unsubscribes'
    end
  end
end