# Grizzled Ruby

## Intro

The Grizzled Ruby Utility Library is a general-purpose Ruby library
with a variety of different modules and classes. Basically, it's an
organized dumping ground for various useful APIs I find I need. It's
similar, in concept, to my [Grizzled Python][] and [Grizzled Scala][]
libraries, for [Python][] and [Scala][], respectively.

It can be built as a gem, but the gem isn't (yet) public.

[Grizzled Python]: http://software.clapper.org/grizzled/
[Grizzled Scala]: http://software.clapper.org/grizzled-scala/
[Scala]: http://www.scala-lang.org/
[Python]: http://www.python.org/

## To build

    $ git clone git://github.com/bmc/grizzled-ruby.git
    $ cd grizzled-ruby
    $ gem build grizzled-ruby.gemspec
    $ gem install grizzled-ruby

## To use in your code

    require 'grizzled'

## Copyright and License

This code is copyright &copy; 2011 Brian M. Clapper and is released under a
BSD License.
