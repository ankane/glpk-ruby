# GLPK Ruby

[GLPK](https://www.gnu.org/software/glpk/) - the GNU linear programming kit - for Ruby

Check out [Opt](https://github.com/ankane/opt) for a high-level interface

[![Build Status](https://github.com/ankane/glpk-ruby/workflows/build/badge.svg?branch=master)](https://github.com/ankane/glpk-ruby/actions)

## Installation

First, install GLPK. For Homebrew, use:

```sh
brew install glpk
```

For Ubuntu, use:

```sh
sudo apt-get install libglpk40
```

And for Fedora, use:

```sh
sudo dnf install glpk
```

Then add this line to your application’s Gemfile:

```ruby
gem "glpk"
```

## Getting Started

*The API is fairly low-level at the moment*

Load a problem

```ruby
problem =
  Glpk.load_problem(
    obj_dir: :minimize,
    obj_coef: [8, 10],
    mat_ia: [1, 2, 3, 1, 2, 3],
    mat_ja: [1, 1, 1, 2, 2, 2],
    mat_ar: [2, 3, 2, 2, 4, 1],
    col_kind: [:integer, :continuous],
    col_lower: [0, 0],
    col_upper: [1e30, 1e30],
    row_lower: [7, 12, 6],
    row_upper: [1e30, 1e30, 1e30]
  )
```

Solve

```ruby
problem.solve
```

Write the problem to an LP or MPS file

```ruby
problem.write_lp("hello.lp")
# or
problem.write_mps("hello.mps")
```

Read a problem from an LP or MPS file

```ruby
problem = Glpk.read_lp("hello.lp")
# or
problem = Glpk.read_mps("hello.mps")
```

## Reference

Set the message level

```ruby
problem.solve(message_level: 4) # 0 = off, 4 = max
```

Set the time limit in seconds

```ruby
problem.solve(time_limit: 30)
```

## History

View the [changelog](https://github.com/ankane/glpk-ruby/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/glpk-ruby/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/glpk-ruby/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/glpk-ruby.git
cd glpk-ruby
bundle install
bundle exec rake test
```
