# Test helper, to force loading from local area first.

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'test/unit'

module GrizzledTestHelper
  def with_tempfile(prefix, suffix, &block)
    temp = Tempfile.new([prefix, suffix])
    begin
      block.call(temp)
    ensure
      temp.close(true)
    end
  end
end
