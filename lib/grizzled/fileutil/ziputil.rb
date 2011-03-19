# Provides convenient, simple front-end functions for the 'rubyzip' gem.
# NOTE: To use this module, you _must_ have the 'rubyzip' gem installed.
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

require 'open-uri'
require 'uri'
require 'pathname'
require 'rubygems'
require 'zip/zip'
require 'fileutils'

module Grizzled

  module FileUtil

    # Namespace module, containing contains some simplified, front-end
    # "zip" and "unzip" utility wrappers for the +rubyzip+ gem. This
    # module requires the +rubyzip+ gem to be present.
    module ZipUtil

      # +ZipMixin+ provides convenient front-end methods for zipping files;
      # it uses the 'rubyzip' gem under the covers, so you must have
      # 'rubyzip' installed to use this class. Mixing this module into your
      # class mixes in methods that will allow you to zip up files. Related
      # modules and classes:
      #
      # Grizzled::FileUtil::Zipper::     A class that includes this module
      #                                  and can be instantiated by itself.
      # Grizzled::FileUtil::UnzipMixin:: A module mixin for unzipping zip files.
      # Grizzled::FileUtil::Unzipper::   A class that includes `UnzipMixin'
      #                                  and can be instantiated by itself.
      module ZipMixin

        # Create a zip file from the contents of a directory.
        #
        # Parameters:
        #
        # zip_file::  The zip file to open. The file is created if it doesn't
        #             already exists.
        # directory:: The directory whose contents are to be included in
        #             the file.
        # options::   Options hash, as described below.
        # select::    If a block (+select+) is given, then +zip+ passes each
        #             file or directory to the block and only adds the entry
        #             to the zip file if the block returns +true+. If no
        #             block is given, then all files and directories are
        #             added (subject also to the +:recursive+ option, below).
        #
        # Options:
        #
        # **NOTE**: Options are symbols (e.g., +:recursive+).
        #
        # recursive::   If +false+, only zip the files in the directory; if
        #               +true+ (the default), recursively zip the entire
        #               directory.
        # dir_at_top::  If +false+, don't include zip the directory itself
        #               (i.e., the top-level files will be at the top level
        #               of the zip file). If +true+ (the default), the
        #               the directory itself (the basename) will be the
        #               top-level element of the zip file.
        # recreate::    If +true+, remove the zip file if it exists already,
        #               so it's recreated from scratch. If +false+ (the 
        #               default), don't recreate the zip file if it doesn't
        #               exist; instead, update the existing file.
        #
        # Returns:
        #
        # The +zip_file+ argument, for convenience.
        #
        # Example:
        #
        #    require 'grizzled/fileutil/ziputil'
        #    import 'tmpdir'
        #
        #    include Grizzled::FileUtil::ZipUtil::ZipMixin
        #
        #    Dir.mktmpdir do |d|
        #      zip zipfile_path, d
        #    end
        def zip(zip_file, directory, options = {}, &select)
          recurse = options.fetch(:recursive, true)
          dir_at_top = options.fetch(:dir_at_top, true)
          recreate = options.fetch(:recreate, true)

          if dir_at_top
            abs_dir = File.expand_path(directory)
            entry_dir = File.basename(abs_dir)
            chdir_to = File.dirname(abs_dir)
            glob = File.join(entry_dir, '**', '*').to_s
          else
            chdir_to = directory
            entry_dir = '.'
            glob = File.join('**', '*').to_s
          end

          # Remove the existing zip file, if asked to do so.
          FileUtils::rm_f zip_file if recreate

          # Open the zip file. Then, CD to the appropriate directory
          # and pack it up.
          zip = Zip::ZipFile.open(zip_file, Zip::ZipFile::CREATE)
          FileUtils::cd chdir_to do |d|
            Dir[glob].each do |path|

              # If the caller supplied a block, only add the file if the block
              # says we can.
              add = block_given? ? select.call(path) : true
              if add
                if File.directory? path
                  zip.mkdir path if recurse
                else
                  zip.add(path, path) if (File.dirname(path) == '.') or recurse
                end
              end
            end
            zip.close
          end
          zip_file
        end
      end # module ZipMixin

      # +UnzipMixin+ provides convenient front-end methods for unzipping
      # files; it uses the 'rubyzip' gem under the covers, so you must have
      # 'rubyzip' installed to use this class. Mixing this module into your
      # class mixes in methods that will allow you to unzip zip files.
      # Related modules and classes:
      #
      # Grizzled::FileUtil::Zipper::    A class that includes this module
      #                                 and can be instantiated by itself.
      # Grizzled::FileUtil::ZipMixin::  A module mixin for zipping zip files.
      # Grizzled::FileUtil::Unzipper::  A class that includes `UnzipMixin'
      #                                 and can be instantiated by itself.
      module UnzipMixin
        # Unzips a zip file into a directory.
        #
        # Parameters:
        #
        # zip_file::  The zip file to unzip.
        # directory:: The directory into which to unzip the file. The
        #             directory is created if it doesn't already exist.
        # options::   Options hash, as described below.
        # select::    If a block (+select+) is given, then +unzip+ passes each
        #             zip file entry name to the block and only unzips the
        #             entry if the block returns +true+. If no block is
        #             given, then everything is unzipped (subject also to
        #              the +:recursive+ option, below).
        #
        # Options:
        #
        # **NOTE**: Options are symbols (e.g., +:recursive+).
        #
        # recursive::  If +false+, only extract the top-level files from the
        #              zip file. If +true+ (the default), recursively
        #              extract everything.
        # overwrite::  If +false+ (the default), do not overwrite existing
        #              files in the directory. If +true+, overwrite
        #              any existing files in the directory with extracted
        #              zip files whose names match.
        #
        # Example:
        #
        #    import 'grizzled/fileutil/ziputil'
        #    import 'tmpdir'
        #
        #    include Grizzled::FileUtil::ZipUtil
        #
        #    Dir.mktmpdir do |d|
        #      unzip zipfile_path, d
        #      # muck with unpacked contents
        #    end
        def unzip(zip_file, directory, options = {}, &select)
          overwrite = options.fetch(:overwrite, false)
          recurse = options.fetch(:recursive, true)

          zip = Zip::ZipFile.open(zip_file)
          Zip::ZipFile.foreach(zip_file) do |entry|
            file_path = File.join(directory, entry.to_s)
            parent_dir = File.dirname file_path
            if recurse or (parent_dir == '.') or (parent_dir == '')
              # If the caller supplied a block, only extract the file if
              # the block says we can.
              extract = block_given? ? select.call(path) : true
              if extract
                if parent_dir != ''
                  if not File.exists? parent_dir
                    FileUtils::mkdir_p parent_dir
                  end
                end
              end
            end
            zip.extract(entry, file_path)
          end
        end

        # Call a given block with the list of entries in a zip file, without
        # extracting them.
        #
        # Parameters:
        #
        # zip_file::  The zip file to unzip.
        # block::     Block to execute on each entry. If omitted, an
        #             Enumerator is returned. The block receives a string
        #             representing the path of the item in the file.
        def zip_file_entries(zip_file, &block)
          if not block_given?
            a = []
          end

          Zip::ZipFile.foreach(zip_file) do |entry|
            if block_given?
              block.call(entry.to_s)
            else
              a << entry.to_s
            end
          end

          if not block_given?
            return a.each
          end
        end
      end # module UnzipMixin

      # +Zipper+ is a class version of +ZipMixin+ and is useful when you
      # don't want to mix the methods directly into your class or module.
      # It provides the methods of +ZipMixin+ as class methods.
      #
      # Example:
      #
      #    require 'grizzled/fileutil/ziputil'
      #    import 'tmpdir'
      #
      #    include Grizzled::FileUtil::ZipUtil
      #
      #    Dir.mktmpdir do |d|
      #      Zipper.zip zipfile_path, d
      #    end
      class Zipper
        class << self
          include Grizzled::FileUtil::ZipUtil::ZipMixin
        end
      end

      # +Unzipper+ is a class version of +UnzipMixin+ and is useful when
      # you don't want to mix the methods directly into your class or
      # module. It provides the methods of +UnzipMixin+ as class methods.
      #
      #    import 'grizzled/fileutil/ziputil'
      #    import 'tmpdir'
      #
      #    include Grizzled::FileUtil::ZipUtil
      #
      #    Dir.mktmpdir do |d|
      #      Unzipper.unzip zipfile_path, d
      #      # muck with unpacked contents
      #    end
      class Unzipper
        class << self
          include Grizzled::FileUtil::ZipUtil::UnzipMixin
        end
      end

    end # module ZipUtil
  end # module File
end # module Grizzled

