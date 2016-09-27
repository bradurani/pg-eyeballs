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

#### explain(format: [:analyze, :verbose, :costs, :buffers
], format: :text)
```ruby
User.all.eyeballs.explain

["Seq Scan on public.users  (cost=0.00..22.30 rows=1230 width=36) (actual time=0.002..0.002 rows=1 loops=1)
    Output: id, email
    Buffers: shared hit=1
  Planning time: 0.014 ms\nExecution time: 0.009 ms"]
```
Most eyeballs methods return arrays because an `ActiveRecord::Relation` can run
more than one query, for instance when it has a `preload` or with certain
subqueries
```ruby
User.all.preload(:profiles).eyeballs.explain

["Seq Scan on public.users  (cost=0.00..22.30 rows=1230 width=36) (actual time=0.002..0.002 rows=1 loops=1)
    Output: id, email
    Buffers: shared hit=1
  Planning time: 0.013 ms
  Execution time: 0.009 ms",
 "Seq Scan on public.profiles  (cost=0.00..36.75 rows=11 width=8) (actual time=0.003..0.003 rows=1 loops=1)
    Output: id, user_id
    Filter: (profiles.user_id = 1)
    Buffers: shared hit=1
  Planning time: 0.019 ms
  Execution time: 0.009 ms"]
```





## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bradurani/pg-eyeballs. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

