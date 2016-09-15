module Eyeballs
  class Inspector

    def initialize(relation)
      @relation = relation
    end

    def explain
      ActiveRecord::ExplainRegistry.queries.each do |query|

      end
    end

    def inspect
      @relation.explain
    end

  end
end
