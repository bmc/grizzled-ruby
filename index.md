---
title: The Grizzled Ruby Utility Library
layout: withTOC
---

## Introduction

The Grizzled Ruby Utility Library is a general-purpose Ruby library
with a variety of different modules and classes. Basically, it's an
organized dumping ground for various useful APIs I find I need. It's
similar, in concept, to my [Grizzled Python][] and [Grizzled Scala][]
libraries, for [Python][] and [Scala][], respectively.

It can be built as a gem, but the gem isn't (yet) public.

## To build

    $ git clone git://github.com/bmc/grizzled-ruby.git
    $ cd grizzled-ruby
    $ gem build grizzled-ruby.gemspec
    $ gem install grizzled-ruby

## To use in your code

    require 'rubygems'
    require 'grizzled/unix'
    require 'grizzled/string/template'
    # etc.
    
## API documentation

The [RDoc][]-generated API documents are [here](apidocs/).

## Author

Brian M. Clapper, [bmc@clapper.org][]

## Copyright and License

The Grizzled Scala Library is copyright &copy; 2009-2010 Brian M. Clapper
and is released under a [BSD License][].

## Patches

I gladly accept patches from their original authors. Feel free to email
patches to me or to fork the [GitHub repository][] and send me a pull
request. Along with any patch you send:

* Please state that the patch is your original work.
* Please indicate that you license the work to the PROJECT project
  under a [BSD License][].

[Grizzled Python]: http://software.clapper.org/grizzled/
[Grizzled Scala]: http://software.clapper.org/grizzled-scala/
[Scala]: http://www.scala-lang.org/
[Python]: http://www.python.org/
[BSD License]: license.html
[GitHub repository]: http://github.com/bmc/grizzled-ruby
[GitHub]: http://github.com/bmc/
[downloads area]: http://github.com/bmc/grizzled-ruby/downloads
[bmc@clapper.org]: mailto:bmc@clapper.org
[RDoc]: http://rdoc.sourceforge.net/
