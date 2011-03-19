require '../test_helper'
require 'test/unit'
require 'tempfile'
require 'tmpdir'
require 'fileutils'
require 'grizzled/fileutil'

include Grizzled::FileUtil

class MakeDirTreeTester < Test::Unit::TestCase
  include GrizzledTestHelper

  def test_make_directory_tree
    tree = {"bmc" => {"moe" => {"a" => "aaaaaaaaaa",
                                "b" => "bbbbbbbbb"},
                      "larry" => "larry",
                      "curley" => "curley"}}
    Dir.mktmpdir('ziptest') do |tmpdir|
      make_directory_tree(tmpdir, tree)

      # Now, reload the directory tree, and ensure that the tree
      # matches what we created.
      new_tree = {}
      FileUtils.cd tmpdir do
        new_tree = dir_to_hash "bmc"
      end

      assert_equal tree, new_tree
    end
  end

  private

  def dir_to_hash(dir)

    def load_dir_hash(dir)
      h = {}
      Dir.new(dir).entries.each do |dirent|
        if dirent[0..0] != '.'
          path = File.join(dir, dirent)
          if File.directory? path
            FileUtils.cd dir do
              h[dirent] = load_dir_hash(dirent)
            end
          else
            h[dirent] = File.open(path).read
          end
        end
      end
      h
    end

    {dir => load_dir_hash(dir)}
  end
end
