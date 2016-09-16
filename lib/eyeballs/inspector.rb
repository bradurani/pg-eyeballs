module Eyeballs
  class Inspector

    def initialize(relation)
      @relation = relation
    end

    def explain(format: :string)
      @explain ||= queries.each do |query|
        explain_query(query)
      end
    end

    def explain_query(query)

    end

    def queries
      @queries ||= query_array.flatten.select(&:present?)
    end

    def inspect
      @relation.explain
    end

    def to_s
      "Eyeballs::Inspector: #{@relation.to_s}"
    end

    private

    def query_array
      @relation.send(:collecting_queries_for_explain) do
        @relation.send(:exec_queries)
      end
    end

  end
end
