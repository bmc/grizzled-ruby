# Grizzled Ruby: A library of miscellaneous, general-purpose Ruby modules.
#
# Author:: Brian M. Clapper (mailto:bmc@clapper.org)
# Copyright:: Copyright (c) 2011 Brian M. Clapper
# License:: BSD License

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
