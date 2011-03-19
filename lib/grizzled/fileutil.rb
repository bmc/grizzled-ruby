# Miscellaneous additional Ruby file utility modules and classes.
#
#--
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
#++

module Grizzled

  # This module and its submodules contain various file-related utility
  # methods.
  module FileUtil

    # Exception thrown for a bad directory tree value.
    class BadDirectoryTreeValue < StandardError
      def initialize(key, value)
        super("Directory tree key '#{key}' has unsupported value '#{value}' " +
              "of type #{value.class}. Values must be hashes or strings.")
      end
    end

    # Exception thrown for bad directory tree key.
    class BadDirectoryTreeKey < StandardError; end

    # Create a file/directory hierarchy. The hash table specifies the
    # entries, using the following rules.
    #
    # - A hash entry whose value is another hash table is taken to
    #   be a directory and will be recursively created.
    # - A hash entry with a String value is a file, whose contents are the
    #   string.
    # - A hash entry with an Enumerable value is a file, whose contents are
    #   the enumerable values, rendered as strings.
    # - Anything else is an error.
    #
    # For instance, this hash:
    #
    #    tree = {"foo" =>
    #              {"bar"   => {"a" => "File a's contents",
    #                           "b" => "File b's contents"},
    #               "baz"   => {"c" => "Blah blah blah"},
    #               "xyzzy" => "Yadda yadda yadda"}}
    #
    # results in this directory tree:
    #
    #     foo/
    #         bar/
    #             a   # File a's contents
    #             b   # File a's contents
    #
    #         baz/
    #             c   # Blah blah blah
    #
    #         xyzzy   # Yadda yadda yadda
    #
    # The keys should be simple file names, with no file separators (i.e.,
    # no parent directories).
    #
    # Parameters:
    #
    # [+directory+] The starting directory, which is created if it does not
    #               exist.
    # [+tree+]      The entry tree, as described above
    #
    # Returns:
    #
    # A +Dir+ object for +directory+, for convenience.
    def make_directory_tree(directory, tree)

      require 'fileutils'

      if File.exists? directory
        if not File.directory? directory
          raise BadDirectoryTreeKey.new("Directory '#{directory}' already " +
                                        "exists and isn't a directory.")
        end
      else
        Dir.mkdir directory
      end

      FileUtils.cd directory do
        tree.each do |entry, contents|
          if entry.include? File::SEPARATOR
            raise BadDirectoryTreeKey.new("File tree key '#{key}' contains " +
                                          "illegal file separator character.");
          end

          # Must test Hash first, because Hash is Enumerable.

          if contents.kind_of? Hash
            # This is a directory
            make_directory_tree(entry, contents)

          elsif contents.kind_of? Enumerable
            f = File.open(File.join(entry), 'w')
            contents.each {|thing| f.write(thing.to_s)}
            f.close

          else
            raise BadDirectoryTreeValue.new(entry, contents)
          end
        end
      end

      return Dir.new(directory)
    end

  end # Module FileUtil
end # module Grizzled
