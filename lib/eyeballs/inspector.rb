module Eyeballs
  class Inspector

    OPTIONS = [:analyze, :verbose, :costs, :buffer]
    FORMATS = [:text, :xml, :json, :yaml]

    def initialize(relation)
      @relation = relation
    end

    def explain(format: :text, options: OPTIONS)
      validate_format!(format)
      validate_options!(options)
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

    def validate_format!(format)
      unless FORMATS.include?(format)
        raise Eyeballs::UnknownFormatError, "Unknown Format #{format}" 
      end
    end

    def validate_options!(options)
      options.each do |option|
        unless OPTIONS.include?(option)
          raise Eyeballs::UnknownOptionError, "Unknown Option #{option}" 
        end
      end
    end


  end
end
