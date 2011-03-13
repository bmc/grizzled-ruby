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
module Grizzled

  # Thrown for un-safe stacks if the stack
  class StackUnderflowException < StandardError; end

  # A simple stack wrapper on top of a Ruby array, providing a little more
  # protection that using an array directly.
  class Stack

    include Enumerable

    attr_reader :pop_empty_nil

    # Initialize a new stack.
    #
    # Parameters:
    #
    # [+pop_empty_nil+]  +true+ if popping an empty stack should just return
    #                    +nil+, +false+ if it should thrown an exception.
    def initialize(pop_empty_nil=true)
      @the_stack = []
      @pop_empty_nil = pop_empty_nil
    end

    # Pop the top element from the stack. If the stack is empty, this method
    # throws a +StackUnderflowException+, if +pop_empty_nil+ is +false+; or
    # returns nil, if +pop_empty_nil+ is +true+.
    def pop
      if (@the_stack.length == 0) && (not @pop_empty_nil)
        raise StackUnderflowException.new
      end
      @the_stack.pop
    end

    # Pop every element of the stack, returning the results as an array
    # and clearing the stack.
    def pop_all
      result = @the_stack.reverse
      @the_stack.clear
      result
    end

    # Convenience method for +length == 0+.
    def is_empty?
      length == 0
    end

    # Push an element or an array of elements onto the stack. Returns the
    # stack itself, to allow chaining. Note: If you push an array of elements,
    # the elements end up being reversed on the stack. That is, this:
    #
    #     stack = Stack.new.push([1, 2, 3]) # yields Stack[3, 2, 1]
    #
    # is equivalent to
    #
    #     stack = Stack.new
    #     [1, 2, 3].each {|i| stack.push i}
    def push(element)
      if element.class == Array
        element.each {|e| @the_stack.push e}
      else
        @the_stack.push element
      end
      self
    end

    # Returns the size of the stack.
    def length
      @the_stack.length
    end

    # Yield each element of the stack, in turn. Unaffected by a change in
    # the stack.
    def each
      self.to_a.each do |element|
        yield element
      end
    end

    # Clear the stack. Returns the stack, for chaining.
    def clear
      @the_stack.clear
      self
    end

    # Printable version.
    def inspect
      @the_stack.inspect
    end

    # Return the stack as an array.
    def to_a
      @the_stack.reverse
    end

    # Return the stack's hash.
    def hash
      @the_stack.hash
    end

    # Determine if this hash is equal to another one.
    def eql?(other)
      (other.class == Stack) and (other.to_a == to_a)
    end

    # Compare this stack to another element.
    def <=>(other)
      if other.class == Stack
        other.to_a <=> to_a
      else
        other.to_s <=> this.to_s
      end
    end
  end
end
