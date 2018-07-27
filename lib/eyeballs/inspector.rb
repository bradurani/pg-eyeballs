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
      @relation.connection.to_sql(query_array).map { |query|
        build_sql(query)
      }
    end

    def to_s(options: OPTIONS)
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
      to_hash_array.each { |h| puts "#{h.to_json }" }
      nil
    end

    def gocmdpev
      to_hash_array.each do |h|
        system("echo '#{h.to_json}' | gocmdpev")
      end
      nil
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
      query_binding[1].each.with_index.reduce(query_binding[0]) do |sql,(value, index)|
        sql.sub("$#{index + 1}", @relation.connection.quote(extract_value(value)))
      end
    end

    def extract_value(value)
      if value.is_a?(Array) #Rails 4
        value.last
      elsif value.is_a?(ActiveRecord::Relation::QueryAttribute) #Rails 5
        value.value
      end
    end

  end
end
