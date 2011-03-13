require '../test_helper'
require 'test/unit'
require 'tempfile'
require 'grizzled/fileutil/includer'

include Grizzled::FileUtil

class IncluderTestDriver < Test::Unit::TestCase

  def test_successful_file_include
    temp1 = Tempfile.new('inctest')
    temp2 = Tempfile.new('inctest')
    begin
      temp2.write <<EOF2
one-2
two-2
EOF2

      temp1.write <<EOF1
one-1
%include "#{temp2.path}"
two-1
EOF1
      temp1.close
      temp2.close
      inc = Includer.new(temp1.path)
      lines = inc.readlines.map {|line| line.chomp}
      assert_equal(['one-1', 'one-2', 'two-2', 'two-1'], lines)
    ensure
      temp1.unlink
      temp2.unlink
    end
  end

  def test_recursive_include
    temp = Tempfile.new('inctest')
    temp.write <<EOF
%include "#{temp.path}"
EOF
    temp.close
    assert_raise(IncludeException) do
      inc = Includer.new(temp.path)
      inc.readlines
    end
  end

  def test_uri_include
    temp1 = Tempfile.new('inctest')
    temp2 = Tempfile.new('inctest')
    begin
      temp2.write <<EOF2
one-2
two-2
EOF2

      temp1.write <<EOF1
one-1
%include "#{temp2.path}"
two-1
EOF1
      temp1.close
      temp2.close
      inc = Includer.new("file://#{temp1.path}")
      lines = inc.readlines.map {|line| line.chomp}
      assert_equal(['one-1', 'one-2', 'two-2', 'two-1'], lines)
    ensure
      temp1.unlink
      temp2.unlink
    end
  end

end
