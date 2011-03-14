# Provides a module which, when mixed in, can be used to forward all
# missing methods to another object.
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

module Grizzled

  # +Forwarder+ makes it easy to forward calls to another object.
  #
  # Examples:
  #
  # Forward all unimplemented methods to a file:
  #
  #    class Test
  #      include Grizzled::Forwarder
  # 
  #      def initialize(file)
  #        forward_to file
  #      end
  #    end
  #
  #    Test.new(File.open('/tmp/foobar')).each_line do |line|
  #      puts(line)
  #    end
  #
  # Forward all unimplemented calls, _except_ +each+ to the specified
  # object. Calls to +each+ will raise a +NoMethodError+:
  #
  #    class Test
  #      include Grizzled::Forwarder
  # 
  #      def initialize(file)
  #        forward_to file, [:each]
  #      end
  #    end
  module Forwarder

    # Forward all unimplemented method calls to +obj+, except those
    # whose symbols are listed in the +exceptions+ array.
    def forward_to(obj, exceptions=[])
      @forward_obj = obj

      require 'set'

      @forwarder_exceptions = Set.new(exceptions)
      class << self
        def method_missing(m, *args, &block)
          if not @forwarder_exceptions.include? m
            @forward_obj.send(m, *args, &block)
          else
            super(m, *args, &block)
          end
        end
      end
    end
  end
end
