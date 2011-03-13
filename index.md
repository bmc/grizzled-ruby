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

This library contains a variety of potentially useful modules, including:

* An include file preprocessor
* A variable-substitution library reminiscent of Python's `StringTemplate`
  module
* A directory-walking API

## To build

First, ensure that you have both `rubygems` and `rake` installed. Then:

    $ git clone git://github.com/bmc/grizzled-ruby.git
    $ cd grizzled-ruby
    $ rake install

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

[Grizzled Python]: http://software.clapper.org/grizzled-python/
[Grizzled Scala]: http://software.clapper.org/grizzled-scala/
[Scala]: http://www.scala-lang.org/
[Python]: http://www.python.org/
[BSD License]: license.html
[GitHub repository]: http://github.com/bmc/grizzled-ruby
[GitHub]: http://github.com/bmc/
[downloads area]: http://github.com/bmc/grizzled-ruby/downloads
[bmc@clapper.org]: mailto:bmc@clapper.org
[RDoc]: http://rdoc.sourceforge.net/
