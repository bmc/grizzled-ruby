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
      #             ftp), or an object with an +each_line+ method that returns
      #             individual lines of input.
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
        @temp = nil
        @source = source
        @closed = false
      end

      # Read the entire include file into an array.
      def readlines
        a = []
        each_line do |line|
          a << line
        end
        a
      end

      # Given a block, passes each input line (after include processing)
      # to the block.
      def each_line(ignored=nil)
        if not @closed
          if @temp.nil?
            preprocess(@source)
          end

          File.open(@temp.path) do |f|
            f.each_line do |line|
              yield line
            end
          end

          @temp.close
          @temp.unlink
          @temp = nil
          @closed = true
        end
      end

      alias :each :each_line

      private

      def preprocess(source)

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

        if source.class == String
          input = open_source(URI::parse(source))
        elsif source.respond_to? :each_line
          input = IncludeSource.new(source, nil)
        else
          raise IncludeException.new("Bad input of class #{source.class}")
        end

        @temp = Tempfile.new('grizzled_includer')
        begin
          do_read(input, @temp, 1)
        ensure
          @temp.close
        end
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

