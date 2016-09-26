require 'spec_helper'

describe Eyeballs::Inspector do

  let(:foo){ Foo.all.eyeballs }
  let(:foo_bar) do
    Foo.all.preload(:bars).eyeballs
  end

  # describe :inspect do
  #   context :foo do
  #     it 'outputs the query plan' do
  #       expect(foo.inspect).to include 'EXPLAIN for: SELECT "foos".* FROM "foos"'
  #     end
  #   end
  #
  #   context :foo_bar do
  #     it 'outputs the query plan' do
  #       expect(foo_bar.inspect).to include 'EXPLAIN for: SELECT "foos".* FROM "foos"'
  #       expect(foo_bar.inspect).to include 'EXPLAIN for: SELECT "bars".* FROM "bars"'
  #     end
  #   end
  # end

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
  end

  describe :to_s do
    it 'displays class string' do
      expect(foo.to_s).to include 'Eyeballs::Inspector: #<Foo::ActiveRecord_Relation:0x'
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
        "EXPLAIN (ANALYZE,VERBOSE,COSTS,BUFFER,FORMAT TEXT) SELECT \"foos\".* FROM \"foos\""
      ]
    end

    it 'generates explain queries for multiple queries' do
      expect(foo_bar.explain_queries).to eql [
        "EXPLAIN (ANALYZE,VERBOSE,COSTS,BUFFER,FORMAT TEXT) SELECT \"foos\".* FROM \"foos\"",
        "EXPLAIN (ANALYZE,VERBOSE,COSTS,BUFFER,FORMAT TEXT) SELECT \"bars\".* FROM \"bars\" WHERE \"bars\".\"foo_id\" IN (1)"
      ]
    end
  end

end
