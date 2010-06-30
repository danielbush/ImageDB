
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
    DLBImageUtils::ImageDb::DB.new(self.tmpdir)
  end



  # Create a set of images

  def build_images
    return if File.exists?(File.join(test_data,'image-1.jpg'))
    1.upto(6) do |i|
      FileUtils.copy File.join(test_data,'image-w600-h400-72ppi.jpg') , 
        File.join(test_data,'image-'+i.to_s+'.jpg')
    end
  end

  # Create a db with some images

  def build rel_root=nil
    build_images
    if rel_root.nil?
      db = DLBImageUtils::ImageDb::DB.new(ITestUtils.tmpdir)
    else
      db = DLBImageUtils::ImageDb::DB.new(ITestUtils.tmpdir,rel_root)
    end
    1.upto(6) do |i|
      db.store File.join(test_data,'image-'+i.to_s+'.jpg')
    end
    db
  end

  def hooks
    hooks = Class.new
    hooks.module_eval do
      attr_reader :count,:params
      def initialize
        @count = Hash.new(0)
      end
      def create params
        @count[:creates] += 1
        @params = params
      end
      def delete params
        @count[:deletes] += 1
        @params = params
      end
    end
    hooks.new
  end

  def test_data
    File.join(File.dirname(__FILE__) , 'test_data')
  end

  def test_image1
    File.join(File.dirname(__FILE__) , 'test_data','image-w600-h400-72ppi.jpg')
  end

end
