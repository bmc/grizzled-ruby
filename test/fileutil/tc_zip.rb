require '../test_helper'
require 'test/unit'
require 'tempfile'
require 'tmpdir'
require 'grizzled/fileutil/ziputil'

include Grizzled::FileUtil::ZipUtil

class ZipMixinTestDriver < Test::Unit::TestCase
  include GrizzledTestHelper
  include ZipMixin, UnzipMixin

  def test_zip_unzip_with_dir
    with_tempfile('ziptest', '.zip') do |t|

      # Create a zip file of the current directory
      zip t.path, '.'
      assert_equal(true, File.exists?(t.path))

      # Now, unzip it and compare this file with its zipped-and-unzipped
      # counterpart.
      this_file_size = File.size(__FILE__)
      this_file_contents = File.open(__FILE__).readlines.join('')
      Dir.mktmpdir('ziptest') do |tmpdir|
        unzip t.path, tmpdir

        # File was unzipped under this directory name.
        entry_dir = File.basename(File.dirname(File.expand_path(__FILE__)))
        unzipped_this_file = File.join(tmpdir, entry_dir,
                                       File.basename(__FILE__))
        FileUtils.cd(tmpdir) do
          assert_equal true, File.exists?(unzipped_this_file)
          assert_equal this_file_size, File.size(unzipped_this_file)
          contents = File.open(unzipped_this_file).readlines.join('')
          assert_equal this_file_contents, contents
        end
      end
    end
  end

  def test_zip_unzip_without_dir
    with_tempfile('ziptest', '.zip') do |t|

      # Create a zip file of the current directory
      zip t.path, '.', :dir_at_top => false
      assert_equal(true, File.exists?(t.path))

      # Now, unzip it and compare this file with its zipped-and-unzipped
      # counterpart.
      this_file_size = File.size(__FILE__)
      this_file_contents = File.open(__FILE__).readlines.join('')
      Dir.mktmpdir('ziptest') do |tmpdir|
        unzip t.path, tmpdir

        # File was unzipped in top level.
        unzipped_this_file = File.join(tmpdir, File.basename(__FILE__))
        FileUtils.cd(tmpdir) do
          assert_equal true, File.exists?(unzipped_this_file)
          assert_equal this_file_size, File.size(unzipped_this_file)
          contents = File.open(unzipped_this_file).readlines.join('')
          assert_equal this_file_contents, contents
        end
      end
    end
  end

  def test_non_recursive
    expected_files = ['foo.txt', 'bar.txt'].sort
    Dir.mktmpdir 'ziptest' do |tmpdir|
      FileUtils.cd tmpdir do

        expected_files.each { |f| create_file(f, (f * 5) + "\n") }

        # Now create a subdirectory.
        Dir.mkdir 'subdir' do |subdir|
          FileUtils.cd subdir do
            # Create a couple more files which should NOT be zipped.
            ['moe', 'larry', 'curley'].each { |f| create_file(f, f) }
          end
        end
      end

      # Now, zip up the temporary directory.

      with_tempfile('ziptest', '.zip') do |t|
        zip t.path, tmpdir, :dir_at_top => false, :recursive => false

        assert_equal expected_files, zip_file_entries(t.path).to_a.sort
      end
    end
  end

  def test_zip_with_block
    create_files = ['foo.txt', 'bar.txt']
    expected_files = ['foo.txt']

    Dir.mktmpdir 'ziptest' do |tmpdir|
      FileUtils.cd tmpdir do
        create_files.each { |f| create_file(f, (f * 5) + "\n") }
      end

      with_tempfile('ziptest', '.zip') do |t|
        zip t.path, tmpdir, :dir_at_top => false, :recursive => false do |path|
          expected_files.include? path
        end

        assert_equal expected_files, zip_file_entries(t.path).to_a
      end
    end
  end

  def test_zip_file_entries
    with_tempfile('ziptest', '.zip') do |t|

      # Create a zip file of the current directory
      zip t.path, '.', :dir_at_top => false, :recursive => false
      assert_equal(true, File.exists?(t.path))

      files_here = Dir.entries('.').select {|e| File.file? e}
      entries = Hash[* files_here.map {|e| [e, 0]}.flatten]

      zip_file_entries t.path do |e|
        assert entries.has_key? e
        entries[e] = 1
      end

      assert_equal 0, (entries.values.select {|v| v == 0}).length
    end
  end

  private

  def create_file(path, contents)
    f = File.open(path, 'w')
    f.write(contents)
    f.close
  end

end
