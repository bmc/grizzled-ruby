---
title: The Grizzled Ruby Utility Library
layout: withTOC
---

# Introduction

The Grizzled Ruby Utility Library is a general-purpose Ruby library with a
variety of different modules and classes, as well as a few potentially
useful executables based on those APIs. Basically, it's an organized
dumping ground for various useful APIs I find I need. It's similar, in
concept, to my [Grizzled Python][] and [Grizzled Scala][] libraries, for
[Python][] and [Scala][], respectively.

It can be installed as a [gem][rubygems].

# The Library

This library contains a variety of potentially useful modules, including:

* An include file preprocessor
* A variable-substitution library reminiscent of Python's `StringTemplate`
  module
* A directory-walking API
* A mixin that makes forwarding method calls easier.

To use the various packages in your code, first pull in `rubygems`, followed
by the Grizzled Ruby package or packages you need. For example:

    require 'rubygems'
    require 'grizzled/unix'
    require 'grizzled/string/template'

## API documentation

The [RDoc][]-generated API documents are [here](apidocs/).

# Installation

## From RubyGems.org

Grizzled Ruby is a [published gem][]. To install, make sure [rubygems][]
is installed, then run this command. (You may need to run it as *root*,
depending on your permissions, whether you're using [rvm][], etc.)

    $ gem install grizzled-ruby

## From source

First, ensure that you have both `rubygems` and `rake` installed. Then, either
clone the [git repository][] or [download the source][] and unpack it. Then:

    $ cd grizzled-ruby
    $ rake install
   
# Author

Brian M. Clapper, [bmc@clapper.org][]

# Copyright and License

The Grizzled Ruby Library is copyright &copy; 2011 Brian M. Clapper
and is released under a [BSD License][].

# Change Log

The [change log][CHANGELOG] is [here][CHANGELOG].

# Patches

I gladly accept patches from their original authors. Feel free to email
patches to me or to fork the [git repository][] and send me a pull
request. Along with any patch you send:

* Please state that the patch is your original work.
* Please indicate that you license the work to the Grizzled Ruby project
  under a [BSD License][].

[Grizzled Python]: http://software.clapper.org/grizzled-python/
[Grizzled Scala]: http://software.clapper.org/grizzled-scala/
[Scala]: http://www.scala-lang.org/
[Python]: http://www.python.org/
[BSD License]: license.html
[git repository]: http://github.com/bmc/grizzled-ruby
[GitHub]: http://github.com/bmc/
[downloads area]: http://github.com/bmc/grizzled-ruby/downloads
[bmc@clapper.org]: mailto:bmc@clapper.org
[RDoc]: http://rdoc.sourceforge.net/
[rubygems]: http://rubygems.org/
[published gem]: https://rubygems.org/gems/grizzled-ruby
[rvm]: http://rvm.beginrescueend.com/
[download the source]: https://github.com/bmc/grizzled-ruby/archives/master
[CHANGELOG]: https://github.com/bmc/grizzled-ruby/blob/master/CHANGELOG.md
