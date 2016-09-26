module Eyeballs
  class Inspector

    OPTIONS = [:analyze, :verbose, :costs, :buffers]
    FORMATS = [:text, :xml, :json, :yaml]

    def initialize(relation)
      @relation = relation
    end

    def explain(format: :text, options: OPTIONS)
      explain_queries(format: format, options: options).map do |query|
        run_query(query)
      end
    end

    def explain_queries(format: :text, options: OPTIONS)
      validate_format!(format)
      validate_options!(options)
      @explain ||= queries.map do |query|
        explain_query(query, format, options)
      end
    end

    def queries
      @queries ||= query_array.flatten.select(&:present?)
    end

    def to_s
      explain.join("\n\n")
    end

    def to_json
      explain(format: :json)
    end

    def inspect
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

    def explain_query(query, format, options)
     "EXPLAIN (#{explain_options(format, options)}) #{query}" 
    end

    def explain_options(format, options)
      options.map(&:upcase).tap { |a| a << "FORMAT #{format.upcase}" }.join(',')
    end
    
    def run_query(sql)
      @relation.connection.raw_connection.exec(sql).values.join("\n")
    end
  end
end
