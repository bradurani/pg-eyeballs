require 'spec_helper'

describe Eyeballs::Inspector do
  let(:foo){ Foo.all.eyeballs }
  let(:foo_bar) do
    Foo.all.preload(:bars).eyeballs
  end
  let(:foo_paginate) { Foo.limit(10).offset(0).all.eyeballs }

  describe :queries do
    context :foo do
      it 'returns array of queries' do
        expect(foo.queries.length).to eql 1
        expect(foo.queries[0]).to include 'SELECT "foos".* FROM "foos"'
      end
    end

    context :foo_bar do
      it 'returns array of queries' do
        expect(foo_bar.queries.length).to eql 2 
        expect(foo_bar.queries[0]).to include 'SELECT "foos".* FROM "foos"'
        expect(foo_bar.queries[1]).to include 'SELECT "bars".* FROM "bars"'
      end
    end

    context :foo_paginate do
      it 'returns array of queries' do
        expect(foo_paginate.queries.length).to eql 1
        expect(foo_paginate.queries[0]).to include "LIMIT 10 OFFSET 0"
      end
    end
  end

  describe :to_s do
    context :foo_bar do
      it 'concatenates the query plans with blank line' do
        expect(foo_bar.to_s).to include 'Seq Scan on public.foos  (cost='
        expect(foo_bar.to_s).to include 'Seq Scan on public.bars  (cost='
      end
    end
  end

  describe :explain_queries do
    it 'validates format' do
      expect { foo.explain_queries(format: :toml) }.to raise_error Eyeballs::UnknownFormatError 
    end

    it 'validates options' do
      expect { foo.explain_queries(options: [:analyze, :explain]) }.to raise_error Eyeballs::UnknownOptionError
    end

    it 'generates explain queries' do
      expect(foo.explain_queries).to eql [
        "EXPLAIN (ANALYZE,VERBOSE,COSTS,BUFFERS,FORMAT TEXT) SELECT \"foos\".* FROM \"foos\""
      ]
    end

    it 'generates explain queries for multiple queries' do
      result = foo_bar.explain_queries
      rails4version = [
        "EXPLAIN (ANALYZE,VERBOSE,COSTS,BUFFERS,FORMAT TEXT) SELECT \"foos\".* FROM \"foos\"",
        "EXPLAIN (ANALYZE,VERBOSE,COSTS,BUFFERS,FORMAT TEXT) SELECT \"bars\".* FROM \"bars\" WHERE \"bars\".\"foo_id\" IN (1)"
      ]
      rails5version = [
        "EXPLAIN (ANALYZE,VERBOSE,COSTS,BUFFERS,FORMAT TEXT) SELECT \"foos\".* FROM \"foos\"",
        "EXPLAIN (ANALYZE,VERBOSE,COSTS,BUFFERS,FORMAT TEXT) SELECT \"bars\".* FROM \"bars\" WHERE \"bars\".\"foo_id\" = 1"
      ]
      expect(result == rails4version || result == rails5version).to be true
    end

    it 'generates explain query given options and format' do
      expect(foo.explain_queries(format: :json, options: [:analyze])).to eql [
        "EXPLAIN (ANALYZE,FORMAT JSON) SELECT \"foos\".* FROM \"foos\""
      ]
    end

    it 'generates sql with integer param' do
      expect(Foo.where(id: 1).eyeballs.explain_queries[0]).to eql "EXPLAIN (ANALYZE,VERBOSE,COSTS,BUFFERS,FORMAT TEXT) SELECT \"foos\".* FROM \"foos\" WHERE \"foos\".\"id\" = 1"
    end
    
    it 'generates sql with string param' do
      expect(Foo.where(name: 'brad').eyeballs.explain_queries[0]).to eql "EXPLAIN (ANALYZE,VERBOSE,COSTS,BUFFERS,FORMAT TEXT) SELECT \"foos\".* FROM \"foos\" WHERE \"foos\".\"name\" = 'brad'"
    end
  end

  describe :explain do
    it 'runs explain query' do
      explain_array = foo.explain
      expect(explain_array.length).to eql 1
      expect(explain_array[0]).to include "Seq Scan on public.foos  (cost="
    end

    it 'runs explain queries' do
      explain_array = foo_bar.explain
      expect(explain_array.length).to eql 2
      expect(explain_array[0]).to include "Seq Scan on public.foos  (cost="
      expect(explain_array[1]).to include "Seq Scan on public.bars  (cost="
    end

    it 'interpolates SQL args' do
      expect(Foo.where(id: 1).eyeballs.explain[0]).to include "Index Scan using foos_pkey"
    end

    it 'works with most data types' do
      expect(Baz.where(id: 1, name: 'brad', d: Date.parse('2016-08-25'), t: Time.now, b: true, n: 3.14).eyeballs.explain).to be_a Array
    end
  end

  describe :inspect do
    it 'displays class string' do
      expect(foo.inspect).to include 'Eyeballs::Inspector: #<Foo::ActiveRecord_Relation:0x'
    end
  end

  describe :to_json do
    it 'returns json array' do
       json_array = foo_bar.to_json.map{|json| JSON.parse(json)}
      expect(json_array.length).to eql 2
      expect(json_array[0][0]).to include('Plan')
      expect(json_array[1][0]).to include('Plan')
    end
  end

  describe :to_hash_array do
    it 'returns hash' do
      json_array = foo_bar.to_hash_array
      expect(json_array.length).to eql 2
      expect(json_array[0][0]).to include('Plan')
      expect(json_array[1][0]).to include('Plan')
    end
  end

  describe :log_json do
    it 'returns 2 json strings separated by new line' do
      output = foo_bar.log_json
      expect(output).to be_nil
    end
  end
end
