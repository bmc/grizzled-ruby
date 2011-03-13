require '../test_helper'
require 'test/unit'
require 'grizzled/string/template'

include Grizzled::String::Template

module TemplateTestDriver

  def do_safe_expansion(template_class, resolver, test_data)
    u = template_class.new(resolver, :safe => true)
    test_data.each do |string, expected, has_missing|
      assert_equal(expected, u.substitute(string))
    end
  end

  def do_unsafe_expansion(template_class, resolver, test_data)
    u = template_class.new(resolver, :safe => false)
    test_data.each do |string, expected, has_missing|
      if has_missing
        assert_raise(VariableNotFoundException) do
          u.substitute(string)
        end
      end
    end
  end
end

class TestUnixShellStringTemplate < Test::Unit::TestCase

  include TemplateTestDriver

  RESOLVER  = {"a" => "alpha", "foo" => "FOOBAR"}
  TEST_DATA = 
    [
     ['${a} $foo ${b?bdef} $b ${foo}\$x', 'alpha FOOBAR bdef  FOOBAR$x', true],
     ['\$a $foo $b', '$a FOOBAR ', true],
     ['$a', 'alpha', false]
    ]

  def test_safe_expansion
    do_safe_expansion(UnixShellStringTemplate, RESOLVER, TEST_DATA)
  end

  def test_unsafe_expansion
    do_unsafe_expansion(UnixShellStringTemplate, RESOLVER, TEST_DATA)
  end
end

class TestWindowsCmdStringTemplate < Test::Unit::TestCase

  include TemplateTestDriver

  RESOLVER  = {"a" => "alpha", "foo" => "FOOBAR"}
  TEST_DATA = 
    [
     ['%a% %foo% %b% %foo%\%x', 'alpha FOOBAR  FOOBAR%x', true],
     ['\%a% %foo% %b%', '%a% FOOBAR ', true],
     ['%a%', 'alpha', false]
    ]

  def test_safe_expansion
    do_safe_expansion(WindowsCmdStringTemplate, RESOLVER, TEST_DATA)
  end

  def test_unsafe_expansion
    do_unsafe_expansion(WindowsCmdStringTemplate, RESOLVER, TEST_DATA)
  end
end
