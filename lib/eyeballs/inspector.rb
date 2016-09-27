module Eyeballs
  class Inspector

    OPTIONS = [:analyze, :verbose, :costs, :buffers]
    FORMATS = [:text, :xml, :json, :yaml]

    def initialize(relation)
      @relation = relation
    end

    def explain(format: :text, options: OPTIONS)
      @explain ||= explain_queries(format: format, options: options).map do |query|
        run_query(query)
      end
    end

    def explain_queries(format: :text, options: OPTIONS)
      validate_format!(format)
      validate_options!(options)
      @explain_queries ||= queries.map do |query|
        explain_query(query, format, options)
      end
    end

    def queries
      @queries ||= query_array.map do |query_binding|
        build_sql(query_binding)
      end
    end

    def to_s
      explain.join("\n\n")
    end

    def to_json(options: OPTIONS)
      explain(options: options, format: :json)
    end

    def to_hash_array(options: OPTIONS)
      to_json(options: options).map { |json| JSON.parse(json) }
    end

    def inspect
      "Eyeballs::Inspector: #{@relation.to_s}"
    end

    def log_json(options: OPTIONS)
      to_hash_array.map { |h| h.to_json }.join("\n")
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

    def build_sql(query_binding)
      sql = query_binding[0]
      values = query_binding[1].map do |b|
        cast_type = b[0].cast_type
        cast_value = cast_type.type_cast_for_database(b[1])
        cast_value.is_a?(String) ? "'#{cast_value}'" : cast_value
      end
      values.each.with_index.reduce(sql) do |sql,(value, index)|
        sql.sub("$#{index + 1}", value.to_s)
      end
    end
  end
end
