require 'ostruct'

# Adapted from https://gist.github.com/1120383
#
# Wraps multiple objects in a single object. Method calls are resolved by
# cycling through all wrapped objects, in the order they were specified on
# the constructor, looking for the appropriate named method. Useful for
# temporarily adding methods to an instance, without monkeypatching the
# class.
#
# WrapMany has special-case logic for OpenStruct objects, Hash objects and
# object fields. Hash keys, OpenStruct fields, and public instance
# variables will be resolved, but only for calls made with no parameters.
#
# Example 1: Add an "age" value to a User object using an OpenStruct
#
#     require 'ostruct'
#     require 'grizzled/wrapmany'
#
#     age_holder = OpenStruct.new(:age => 43)
#     u = User.find(...)
#     user_with_age = WrapMany.new(u, age_holder)
#
# Example 2: Add an "age" value to a User object using a hash
#
#     require 'grizzled/wrapmany'
#
#     u = User.find(...)
#     user_with_age = WrapMany.new(u, {:age => 43})
#
# Example 3: Add an "age" value to a User object using another class
#
#     require 'grizzled/wrapmany'
#
#     class AgeHolder
#         def initialize(age)
#             @age = age
#         end
#     end
#
#     u = User.find(...)
#     user_with_age = WrapMany.new(u, AgeHolder.new(43))
class WrapMany
  def initialize(*args)
    # Map any OpenStruct objects in the arguments to hashes, and add the
    # current object (in case someone subclasses this class)
    @objects = args.to_a.map {
      |a| a.is_a?(OpenStruct) ? a.instance_variable_get("@table") : a
    } + [self]
  end

  def method_missing(meth, *args, &block)
    method_name = meth.to_s

    # Loop through all objects, looking for something that satisfies the
    # method name.
    @objects.each do |o|

      # First determine if the method exists as a public instance method.
      # If so, call it.
      if o.class.public_instance_methods.include? method_name.to_sym
        return o.send(method_name, *args, &block)
      end

      # Otherwise, if there are no arguments, then check for fields and
      # hash keys
      if args.length == 0
        if o.instance_variables.include? ":@#{method_name}"
          return o.instance_variable_get method_name
        end

        # Special case for hash
        if o.is_a? Hash
          if o.has_key? meth
            return o[meth]
          elsif o.has_key? method_name
            return o[method_name]
          end
        end
      end

    end

    raise NoMethodError.new("Undefined method: '#{method_name}'", meth)
  end
end
