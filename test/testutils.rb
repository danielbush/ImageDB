
module ITestUtils

  @tmpdir = '/tmp/image-db-tests'
    # Stores db roots created during testing
  @count = 0
    # Keep track of the number of db roots created


  # Clear out @tmpdir and recreate it

  def self.reset
    # Safeguard:
    unless /^\/tmp\//===@tmpdir then
      raise "Unsafe rm -rf operation on: '#{TMPDIR}'"
    end
    FileUtils.rm_rf @tmpdir
    FileUtils.mkdir_p @tmpdir
  end

  # Make and return a tmpdir

  def self.tmpdir
    if RUBY_PLATFORM =~ /(:?mswin|mingw)/
      raise "You need to alter @tmpdir for windows"
    end
    @count += 1
    root = File.join(@tmpdir,"root-#{@count}")
    FileUtils.mkdir_p root
    root
  end

  # Instantiate a new db

  def self.newdb
    ImageDb::DB.new(self.tmpdir)
  end

end
