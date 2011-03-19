# Miscellaneous Unix-related modules and classes
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

  # Unix-related OS things.
  module Unix

    # A +User+ object allows you to do things with Unix users, such as
    # (for instance) run code as that user.
    class User

      require 'etc'

      # Initialize a new user. The +id+ parameter is either a user name
      # (string) or a UID (integer).
      def initialize(id)
        # Find the user in the password database.
        @pwent = (id.is_a? Integer) ? Etc.getpwuid(id) : Etc.getpwnam(id)
      end

      # Run a block of code as this user.
      #
      # [+block+] the block to execute as that user. It will receive this
      #           +User+ object as a parameter.
      #
      # This function will only run as 'root'.
      #
      # === Example
      #
      #     require 'grizzled/unix'
      #     require 'fileutils'
      #
      #     Grizzled::Unix::User.new('root').run_as |u|
      #       rm_r(File.join('/tmp', '*')) # Yeah, this is dangerous
      #     end
      def run_as(&block)

        # Fork the child process. Process.fork will run a given block of
        # code in the child process.
        child = Process.fork do
          # We're in the child. Set the process's user ID.
          Process.uid = @pwent.uid

          # Invoke the caller's block of code.
          block.call(self)
        end

        Process.waitpid(child)
      end
    end
  end
end
