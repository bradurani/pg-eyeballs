module Eyeballs
  class Inspector

    def initialize(relation)
      @relation = relation
    end

    def explain(format: :string)
      queries = @relation.send(:collecting_queries_for_explain) do
        @relation.send(:exec_queries)
      end
      queries.each do |query|
        explain_query(query)
      end
    end

    def explain_query(query)

    end

    def inspect
      @relation.explain
    end

  end
end
