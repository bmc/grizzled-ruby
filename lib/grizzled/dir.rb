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
