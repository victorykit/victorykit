module Queries
  class MembersExport < Export
    def klass
      Member
    end

    def sql
      Member.active.to_sql
    end

    def name
      'active_members'
    end
  end
end