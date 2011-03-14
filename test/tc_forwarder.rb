require 'test_helper'
require 'test/unit'
require 'tempfile'
require 'grizzled/forwarder'

class ForwarderTestDriver < Test::Unit::TestCase

  class ForwardToFile
    include Grizzled::Forwarder

    def initialize(file, exceptions=[])
      forward_to file, exceptions
    end
  end

  def test_forward_all
    path = create_file
    begin
      contents = File.open(path).read

      fwd = ForwardToFile.new(File.open(path))
      contents2 = fwd.read
      assert_equal(contents, contents2)

      lines = []
      fwd = ForwardToFile.new(File.open(path))
      fwd.each_line do |line|
        lines << line
      end
      contents2 = lines.join('')
      assert_equal(contents, contents2)
    ensure
      File.unlink path
    end
  end

  def test_forward_all_but_each
    path = create_file
    begin
      contents = File.open(path).read

      fwd = ForwardToFile.new(File.open(path), [:each])
      contents2 = fwd.read
      assert_equal(contents, contents2)

      assert_raise(NoMethodError) do
        fwd.each
      end
    ensure
      File.unlink path
    end
  end

  def test_forward_all_but_each_and_each_line
    path = create_file
    begin
      contents = File.open(path).read

      fwd = ForwardToFile.new(File.open(path), [:each, :each_line])
      contents2 = fwd.read
      assert_equal(contents, contents2)

      assert_raise(NoMethodError) do
        fwd.each do |c|
          puts(c) # should not get here
        end
      end

      assert_raise(NoMethodError) do
        fwd.each_line do |line|
          puts(line) # should not get here
        end
      end
    ensure
      File.unlink path
    end
  end

  private

  def create_file
    temp = Tempfile.new('fwdtest')
    temp.write((1..80).to_a.join(', '))
    temp.write((1..10).to_a.join(', '))
    temp.close
    temp.path
  end

end
