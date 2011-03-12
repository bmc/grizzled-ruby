# Grizzled Ruby: A library of miscellaneous, general-purpose Ruby modules.
#
# Author:: Brian M. Clapper (mailto:bmc@clapper.org)
# Copyright:: Copyright (c) 2011 Brian M. Clapper
# License:: BSD License

class Dir

  # Adds a +walk+ method to the standard Ruby +Dir+ class. +walk+ walks a
  # directory tree, starting at _dirname_, invoking the supplied block on
  # each directory. The block is passed a +Dir+ object. The directory is
  # walked top-down, not depth-first. To terminate the traversal, the block
  # should return +false+. Anything else (including +nil+) continues the
  # traversal.
  def self.walk(dirname, &block)
    Grizzled::Directory.walk(dirname, &block)
  end

  # Adds an +expand_path+ convenience method to the standard Ruby +Dir+
  # class.
  def expand_path
    File.expand_path(self.path)
  end
end

module Grizzled

  # Useful directory-related methods.
  class Directory

    # Walk a directory tree, starting at _dirname_, invoking the supplied
    # block on each directory. The block is passed a +Dir+ object. The
    # directory is walked top-down, not depth-first. To terminate the
    # traversal, the block should return +false+. Anything else (including
    # +nil+) continues the traversal.
    def self.walk(dirname, &block)
      if block.call(Dir.new(dirname)) != false
        Dir.entries(dirname).each do |entry|
          path = File.join(dirname, entry)
          if File.directory?(path) && (entry != '..') && (entry != '.')
            Grizzled::Directory.walk(path, &block)
          end
        end
      end
      nil
    end
  end
end
