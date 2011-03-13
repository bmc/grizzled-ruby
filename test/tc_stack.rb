require 'test_helper'
require 'test/unit'
require 'grizzled/stack'

include Grizzled

class StackTestDriver < Test::Unit::TestCase

  def test_correct_class
    assert_equal(Grizzled::Stack, Stack.new.class)
  end

  def test_underflow_no_exception
    stack = Stack.new
    assert_equal(nil, stack.pop)
  end

  def test_underflow_exception
    stack = Stack.new(false)
    assert_raise(StackUnderflowException) {stack.pop}
  end

  def test_push
    stack = Stack.new.push(5)
    assert_equal([5], stack.to_a)
    stack.push(10)
    assert_equal([10, 5], stack.to_a)
    stack.push(10)
    assert_equal([10, 10, 5], stack.to_a)
    stack.push([1, 2, 3])
    assert_equal([3, 2, 1, 10, 10, 5], stack.to_a)
  end

  def test_length
    stack = Stack.new.push(5)
    assert_equal(1, stack.length)

    stack.push(5)
    assert_equal(2, stack.length)

    stack.push((1..10).to_a)
    assert_equal(12, stack.length)

    stack.pop
    assert_equal(11, stack.length)

    stack.pop until stack.is_empty?
    assert_equal(0, stack.length)
  end

  def test_clear
    stack = Stack.new.push((1..10).to_a)
    assert_equal(10, stack.length)
    stack.clear
    assert_equal(0, stack.length)
  end

  def test_pop_all
    a = (1..10).to_a
    stack = Stack.new.push(a)
    assert_equal(10, stack.length)
    a2 = stack.pop_all
    assert_equal(0, stack.length)
    assert_equal(a2, a.reverse)
  end

  def test_immutable
    # Ensure that the to_a method doesn't return a stack that's
    stack = Stack.new.push(5).push(10)
    a = stack.to_a
    assert_equal([10, 5], a)
    a.pop
    assert_equal([10, 5], stack.to_a)
  end

  def test_enumerable
    stack = Stack.new.push([1, 2, 3])
    assert_equal([3, 2, 1], stack.to_a)
    a = []
    stack.each {|element| a << element}
    assert_equal(stack.to_a, a)
  end
end
