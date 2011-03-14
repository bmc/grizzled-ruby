# Provides a file inclusion preprocessor. See the documentation for
# the Grizzled::FileUtil::Includer class for complete details.
#
# ---
#
# This software is released under a BSD license, adapted from
# http://opensource.org/licenses/bsd-license.php
#
# Copyright (c) 2011, Brian M. Clapper
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# * Neither the names "clapper.org", "Grizzled Ruby Library", nor the
#   names of its contributors may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ---------------------------------------------------------------------------

require 'open-uri'
require 'uri'
require 'pathname'
require 'grizzled/stack'
require 'tempfile'

module Grizzled

  module FileUtil

    # Thrown when include file processing encounters errors.
    class IncludeException < StandardError; end

    # Internal container for source information.
    class IncludeSource
      URL_PATTERN = %r{^(http|https|ftp)://}

      attr_reader :reader, :uri

      def initialize(reader, uri)
        @reader = reader
        @uri = uri
      end
    end

    # == Introduction
    #
    # An +Includer+ object preprocesses a text file, resolve _include_
    # references. The +Includer+ is an +Enumerable+, allowing iteration over
    # the lines of the resulting expanded file.
    #
    # == Include Syntax
    #
    # The _include_ syntax is defined by a regular expression; any line
    # that matches the regular expression is treated as an _include_
    # directive. The default regular expression matches include directives
    # like this::
    #
    #     %include "/absolute/path/to/file"
    #     %include "../relative/path/to/file"
    #     %include "local_reference"
    #     %include "http://localhost/path/to/my.config"
    #
    # Relative and local file references are relative to the including file
    # or URL. That, if an +Includer+ is processing file "/home/bmc/foo.txt"
    # and encounters an attempt to include file "bar.txt", it will assume
    # "bar.txt" is to be found in "/home/bmc".
    #
    # Similarly, if an +Includer+ is processing URL
    # "http://localhost/bmc/foo.txt" and encounters an attempt to include
    # file "bar.txt", it will assume "bar.txt" is to be found at
    # "http://localhost/bmc/bar.txt".
    #
    # Nested includes are permitted; that is, an included file may, itself,
    # include other files. The maximum recursion level is configurable and
    # defaults to 100.
    #
    # The include syntax can be changed by passing a different regular
    # expression to the +Includer+ class constructor.
    #
    # == Supported Methods
    #
    # +Includer+ supports all the methods of the +File+ class and can be
    # used the same way as a +File+ object is used.
    #
    # == Examples
    #
    # Preprocess a file containing include directives, then read the result:
    #
    #     require 'grizzled/fileutil/includer'
    #     include Grizzled::FileUtil
    #
    #     inc = Includer.new(path)
    #     inc.each do |line|
    #       puts(line)
    #     end
    class Includer

      include Enumerable

      attr_reader :name, :max_nesting

      # Initialize a new +Includer+.
      #
      # Parameters:
      #
      # [+source+]  A string, representing a file name or URL (http, https or
      #             ftp), a +File+ object, or an object with an +each_line+
      #             method that returns individual lines of input.
      # [+options+] Various processing options. See below.
      #
      # Options:
      #
      # [+:max_nesting+]      Maximum include nesting level. Default: 100
      # [+:include_pattern+]  String regex pattern to match include directives.
      #                       Must have a single regex group for the file name
      #                       or URL. Default: ^%include\s"([^"]+)"
      def initialize(source, options={})
        @max_nesting = options.fetch(:max_nesting, 100)
        inc_pattern = options.fetch(:include_pattern, '^%include\s"([^"]+)"')
        @include_re = /#{inc_pattern}/
        includer_source = source_to_includer_source source
        @source_uri = includer_source.uri
        @temp = preprocess includer_source
        @input = File.open @temp.path
      end

      # Return the path of the original include file, if defined. If the
      # original source was a URL, the URL is returned. If the source was a
      # string, nil is returned.
      def path
        @source_uri.path
      end

      # Passes unknown calls through to the underlying open file, if they're
      # supported by the file.
      def method_missing(m, *args, &block)
        if @input.respond_to? m
          @input.send(m, *args, &block)
        else
          raise NoMethodError.new("Undefined method '#{m}' for #{self.class}")
        end
      end

      # Force the underlying resource to be closed.
      def close
        @input.close
        @temp.unlink
      end

      private

      def source_to_includer_source(source)
        if source.class == String
          open_source(URI::parse(source))
        elsif source.class == File
          open_source(URI::parse(source.path))
        elsif source.respond_to? :each_line
          IncludeSource.new(source, nil)
        else
          raise IncludeException.new("Bad input of class #{source.class}")
        end
      end

      def preprocess(includer_source)

        def do_read(input, temp, level)
          input.reader.each_line do |line|
            if m = @include_re.match(line)
              if level >= @max_nesting
                raise IncludeException.new("Too many nested includes " +
                                           "(#{level.to_s}), at: " +
                                           "\"#{line.chomp}\"")
              end
              new_input = process_include(m[1], input)
              do_read(new_input, temp, level + 1)
            else
              temp.write(line)
            end
          end
        end


        temp = Tempfile.new('grizzled_includer')
        begin
          do_read(includer_source, temp, 1)
        ensure
          temp.close
        end

        temp
      end

      # Handle an include reference.
      def process_include(source, parent_input)
        cur_uri = parent_input.uri
        uri = URI::parse(source)
        if (cur_uri != nil) and (uri.scheme == nil)
          # Could be a relative path. Should be relative to the parent input.
          pathname = Pathname.new(source)
          if not pathname.absolute?
            # Not an absolute path, and the including source has a path
            # (i.e., wasn't a string). Make this one relative to the path.
            uri = cur_uri.clone            
            uri.path = File.join(::File.dirname(cur_uri.path), source)
          end
        end

        open_source(uri)
      end

      # Open an input source, based on a parsed URI.
      def open_source(uri)
        case uri.scheme
          when nil then     f = open(uri.path)  # assume file/path
          when 'file' then  f = open(uri.path)  # open path directly
          when 'http' then  f = open(uri.to_s)  # open-uri will handle it
          when 'https' then f = open(uri.to_s)  # open-uri will handle it
          when 'ftp' then   f = open(uri.to_s)  # open-uri will handle it

          else raise IncludeException.new("Don't know how to open #{uri.to_s}")
        end

        IncludeSource.new(f, uri)
      end
    end # class Includer

  end # module File
end # module Grizzled

