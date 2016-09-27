# pg-eyeballs

`pg-eyeballs` is a ruby gem that gives you detailed information about active
record query execution. It gives you `EXPLAIN` output for all queries run by an
active record relation in a way that is configurable and allows you to save
the output to a file.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg-eyeballs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg-eyeballs

## Usage

### explain(options: [:analyze, :verbose, :costs, :buffers], format: :text)

```ruby
User.all.eyeballs.explain

["Seq Scan on public.users  (cost=0.00..22.30 rows=1230 width=36) (actual time=0.002..0.002 rows=1 loops=1)
    Output: id, email
    Buffers: shared hit=1
  Planning time: 0.014 ms
  Execution time: 0.009 ms"
]
```
Most eyeballs methods return arrays because an `ActiveRecord::Relation` can run
more than one query, for instance when it has a `preload` or with certain
subqueries
```ruby
User.all.preload(:profiles).eyeballs.explain(options: [:verbose], format: :yaml)
['- Plan: 
      Node Type: "Seq Scan"
      Relation Name: "users"
      Schema: "public"
      Alias: "users"
      Startup Cost: 0.00
      Total Cost: 22.30
      Plan Rows: 1230
      Plan Width: 36
      Output: 
      - "id"
      - "email"', 
 '- Plan:     
      Node Type: "Seq Scan"
      Relation Name: "profiles"
      Schema: "public"
      Alias: "profiles"
      Startup Cost: 0.00\
      Total Cost: 36.75
      Plan Rows: 11
      Plan Width: 8
      Output: 
        - "id"
        - "user_id"
        Filter: "(profiles.user_id = 1)"'
]
```
**formats:** :text, :xml, :json, :yaml

### explain_queries(options: [:analyze, :verbose, :costs, :buffers], format: :text)
```ruby
User.all.preload(:profiles).eyeballs.explain_queries
["EXPLAIN (ANALYZE,VERBOSE,COSTS,BUFFERS,FORMAT TEXT) SELECT \"users\".* FROM \"users\"",
 "EXPLAIN (ANALYZE,VERBOSE,COSTS,BUFFERS,FORMAT TEXT) SELECT \"profiles\".* FROM \"profiles\" WHERE \"profiles\".\"user_id\" IN (1)"]
 ```
**formats:** :text, :xml, :json, :yaml

### log_json(options: [:analyze, :verbose, :costs, :buffers])
Prints each JSON plan on a separate line. This is useful for command line
processing with `[xargs`](https://linux.die.net/man/1/xargs) and [`jq`](https://stedolan.github.io/jq/) or
[`gocmdpev`](https://github.com/simon-engledew/gocmdpev)
```ruby
User.all.preload(:profiles).eyeballs.log_json
"[{\"Plan\":{\"Node Type\":\"Seq Scan\",\"Relation Name\":\"users\",\"Schema\":\"public\",\"Alias\":\"users\",\"Startup Cost\":0.0,\"Total Cost\":22.3,\"Plan Rows\":1230,\"Plan Width\":36,\"Actual Startup Time\":0.001,\"Actual Total Time\":0.001,\"Actual Rows\":1,\"Actual Loops\":1,\"Output\":[\"id\",\"email\"],\"Shared Hit Blocks\":1,\"Shared Read Blocks\":0,\"Shared Dirtied Blocks\":0,\"Shared Written Blocks\":0,\"Local Hit Blocks\":0,\"Local Read Blocks\":0,\"Local Dirtied Blocks\":0,\"Local Written Blocks\":0,\"Temp Read Blocks\":0,\"Temp Written Blocks\":0,\"I/O Read Time\":0.0,\"I/O Write Time\":0.0},\"Planning Time\":0.014,\"Triggers\":[],\"Execution Time\":0.008}]\n[{\"Plan\":{\"Node Type\":\"Seq Scan\",\"Relation Name\":\"profiles\",\"Schema\":\"public\",\"Alias\":\"profiles\",\"Startup Cost\":0.0,\"Total Cost\":36.75,\"Plan Rows\":11,\"Plan Width\":8,\"Actual Startup Time\":0.003,\"Actual Total Time\":0.003,\"Actual Rows\":1,\"Actual Loops\":1,\"Output\":[\"id\",\"user_id\"],\"Filter\":\"(profiles.user_id = 1)\",\"Rows Removed by Filter\":0,\"Shared Hit Blocks\":1,\"Shared Read Blocks\":0,\"Shared Dirtied Blocks\":0,\"Shared Written Blocks\":0,\"Local Hit Blocks\":0,\"Local Read Blocks\":0,\"Local Dirtied Blocks\":0,\"Local Written Blocks\":0,\"Temp Read Blocks\":0,\"Temp Written Blocks\":0,\"I/O Read Time\":0.0,\"I/O Write Time\":0.0},\"Planning Time\":0.02,\"Triggers\":[],\"Execution Time\":0.01}]"
```

### queries
```ruby
User.all.preload(:profiles).eyeballs.queries
["SELECT \"users\".* FROM \"users\"",
 "SELECT \"profiles\".* FROM \"profiles\" WHERE \"profiles\".\"user_id\" IN (1)"]
 ```

### to_hash_array(options: [:analyze, :verbose, :costs, :buffers])
```ruby
User.all.preload(:profiles).eyeballs.to_hash_array
[[{"Plan"=>{
    "Node Type"=>"Seq Scan",
    "Relation Name"=>"users",
    "Schema"=>"public",
    "Alias"=>"users",
    "Startup Cost"=>0.0,
    "Total Cost"=>22.3,
    "Plan Rows"=>1230,
    "Plan Width"=>36,
    "Actual Startup Time"=>0.001,
    "Actual Total Time"=>0.001,
    "Actual Rows"=>1,
    "Actual Loops"=>1,
    "Output"=>["id", "email"],
    "Shared Hit Blocks"=>1,
    "Shared Read Blocks"=>0,
    "Shared Dirtied Blocks"=>0,
    "Shared Written Blocks"=>0,
    "Local Hit Blocks"=>0,
    "Local Read Blocks"=>0,
    "Local Dirtied Blocks"=>0,
    "Local Written Blocks"=>0,
    "Temp Read Blocks"=>0,
    "Temp Written Blocks"=>0,
    "I/O Read Time"=>0.0,
    "I/O Write Time"=>0.0},
    "Planning Time"=>0.014,
    "Triggers"=>[],
    "Execution Time"=>0.007}],
[{"Plan"=>{
    "Node Type"=>"Seq Scan",
    "Relation Name"=>"profiles",
    "Schema"=>"public",
    "Alias"=>"profiles",
    "Startup Cost"=>0.0,
    "Total Cost"=>36.75,
    "Plan Rows"=>11,
    "Plan Width"=>8,
    "Actual Startup Time"=>0.003,
    "Actual Total Time"=>0.004,
    "Actual Rows"=>1,
    "Actual Loops"=>1,
    "Output"=>["id", "user_id"],
    "Filter"=>"(profiles.user_id = 1)",
    "Rows Removed by Filter"=>0,
    "Shared Hit Blocks"=>1,
    "Shared Read Blocks"=>0,
    "Shared Dirtied Blocks"=>0,
    "Shared Written Blocks"=>0,
    "Local Hit Blocks"=>0,
    "Local Read Blocks"=>0,
    "Local Dirtied Blocks"=>0,
    "Local Written Blocks"=>0,
    "Temp Read Blocks"=>0,
    "Temp Written Blocks"=>0,
    "I/O Read Time"=>0.0,
    "I/O Write Time"=>0.0},
    "Planning Time"=>0.02,
    "Triggers"=>[],
    "Execution Time"=>0.01}]
]
```

### to_json(options: [:analyze, :verbose, :costs, :buffers])
**alias for** `explain(format: :json)`

### to_s(options: [:analyze, :verbose, :costs, :buffers])

```ruby
User.all.preload(:profiles).eyeballs.to_s
"Seq Scan on public.users  (cost=0.00..22.30 rows=1230 width=36) (actual time=0.001..0.002 rows=1 loops=1)
  Output: id, email
  Buffers: shared hit=1
Planning time: 0.010 ms
Execution time: 0.005 ms

Seq Scan on public.profiles  (cost=0.00..36.75 rows=11 width=8) (actual time=0.002..0.002 rows=1 loops=1)
  Output: id, user_id
  Filter: (profiles.user_id = 1)
  Buffers: shared hit=1
Planning time: 0.013 ms
Execution time: 0.006 ms"
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bradurani/pg-eyeballs. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

