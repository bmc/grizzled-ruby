require '../test_helper'
require 'test/unit'
require 'tempfile'
require 'grizzled/fileutil/includer'

include Grizzled::FileUtil

class IncluderTestDriver < Test::Unit::TestCase
  include GrizzledTestHelper

  def test_successful_file_include
    make_include_file do |test_file|
      inc = Includer.new(test_file.main_file)
      lines = inc.readlines.map {|line| line.chomp}
      assert_equal(['one-1', 'one-2', 'two-2', 'two-1'], lines)
      inc.close
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
      inc.close
    end
  end

  def test_uri_include
    make_include_file do |test_file|
      inc = Includer.new(test_file.main_file)
      lines = inc.readlines.map {|line| line.chomp}
      assert_equal(['one-1', 'one-2', 'two-2', 'two-1'], lines)
      inc.close
    end
  end

  def test_path
    make_include_file do |test_file|
      path = test_file.main_file
      inc = Includer.new(test_file.main_file)
      assert_equal(test_file.main_file, inc.path)
      inc.close
    end
  end

  def test_each_byte
    make_include_file do |test_file|
      inc = Includer.new(test_file.main_file)
      contents = inc.read.split(//)
      inc.close

      inc = Includer.new(test_file.main_file)
      bytes = []
      inc.each_byte do |b|
        bytes << b.chr
      end
      inc.close

      assert_equal(contents, bytes)
    end
  end
    
  private

  def make_include_file
    temp1 = Tempfile.new('inctest')
    temp2 = Tempfile.new('inctest')

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
    t = TestIncludeFile.new([temp1, temp2].map {|t| t.path})
    if block_given?
      begin
        yield t
      ensure
        t.unlink
      end
    else
      t
    end
  end
end

class TestIncludeFile
  attr_reader :main_file

  def initialize(files)
    @main_file = files[0]
    @files = files
  end

  def unlink
    @files.each do |f|
      if File.exists? f
        File.unlink f
      end
    end
  end
end
