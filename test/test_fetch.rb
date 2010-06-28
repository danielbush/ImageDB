require File.dirname(__FILE__) + '/test_helper.rb'
$M = false
#require 'rubygems'
#require 'ruby-debug'

class TestFetch < Test::Unit::TestCase

  Image = ImageFile::Image
  include ITestUtils  # test_helper

  def setup
    ITestUtils.reset
    build_images
  end

  
  #--------------------------------------------------------------
  # fetch tests
  # 
  # - this is a case bash
  # - these tests may intersect with tests in other file(s)
  # - 'fetch' is the most complicated part of image db
  #
  # - we're going to use a little system to pull out all the cases
  # - tests will be labelled like this {group-1}-{group-2}
  # - group 1 is information about the image; group 2 is for the
  #   not found settings
  #   - each group is a 2-letter code
  #     - group 1
  #       - first letter
  #         - o = original, s = sized
  #       - 2nd letter
  #         - e = exists , n = doesn't exist
  #       - examples
  #         - oe = original exists
  #         - sn = sized image doesn't exist
  #     - group 2
  #       - first letter
  #         - n = don't use not found, g = use global not found,
  #           l = local (override) not found setting
  #       - 2nd letter
  #         - e = exists , n = doesn't exist
  #     - examples of both
  #       - oe-n = original exists and not using not found
  #       - se-gn = sized image exists, global not found setting but
  #                 global not found image doesn't exist
  #       
  # - within each case (group1+group2), we will perform
  #   - fetch of original
  #   - fetch of nonexisting sized
  #   - fetch of existing sized
  #   - fetch of nonexisting sized with :resize => false
  #   - fetch of existing sized with :resize => false
  #
  # - this covers the following fetch params:
  #   - :not_found  =  override global not found image settings
  #   - :width/:height = specify an image size
  #   - :resize => false = do not autogenerate a sized image if it doesn't exist
  #   
  # - it leaves out the following, which we'll test separate as required
  #   - :resize => true = force resize
  #   - :absolute = return file system path
  #     - every call to fetch should be doubled with params[:absolute]
  #   - :skiphook = do not run hooks
  # - some of this functionality is tested in the other test file
  

  #--------------------------------------------------------------
  # original exists...

  def oe
    db = ITestUtils.newdb
    db.store(test_image1,:name => 'orig-1.jpg' )
    db.store(test_image1,:name => 'notfound-1.jpg' )
    db.store(test_image1,:name => 'notfound-2.jpg' )
    db
  end

  def test_oe_n
    db = oe
    assert(/orig-1.jpg/===db.fetch('orig-1.jpg'))
    assert !File.exists?(File.join(db.root,'w','102','orig-1.jpg'))
    assert(/w.102.orig-1.jpg/===db.fetch('orig-1.jpg',:width => 102))
    assert File.exists?(File.join(db.root,'w','102','orig-1.jpg'))
    assert(/w.102.orig-1.jpg/===db.fetch('orig-1.jpg',:width => 102))
    assert_nil db.fetch('orig-1.jpg',:width => 112,:resize => false)
    assert(/w.102.orig-1.jpg/===
           db.fetch('orig-1.jpg',
                    :width => 102,
                    :resize => false))
  end

  def test_oe_ge  # global not found exists
    db = oe
    db.use_not_found = true
    db.not_found_image = 'notfound-1.jpg'
    assert(/orig-1.jpg/===db.fetch('orig-1.jpg'))
    assert !File.exists?(File.join(db.root,'w','102','orig-1.jpg'))
    assert(/w.102.orig-1.jpg/===db.fetch('orig-1.jpg',:width => 102))
    assert File.exists?(File.join(db.root,'w','102','orig-1.jpg'))
    assert(/w.102.orig-1.jpg/===db.fetch('orig-1.jpg',:width => 102))
    assert(/w.112.notfound-1.jpg/===
           db.fetch('orig-1.jpg',
                    :width => 112,
                    :resize => false))
    assert(/w.102.orig-1.jpg/===
           db.fetch('orig-1.jpg',
                    :width => 102,
                    :resize => false))
  end

  # We use not found image even if it doesn't exist...

  def test_oe_gn
    db = oe
    db.use_not_found = true
    db.not_found_image = 'notfound-not-here.jpg'
    assert(/orig-1.jpg/===db.fetch('orig-1.jpg'))
    assert !File.exists?(File.join(db.root,'w','102','orig-1.jpg'))
    assert(/w.102.orig-1.jpg/===db.fetch('orig-1.jpg',:width => 102))
    assert File.exists?(File.join(db.root,'w','102','orig-1.jpg'))
    assert(/w.102.orig-1.jpg/===db.fetch('orig-1.jpg',:width => 102))
    assert(/w.112.notfound-not-here.jpg/===
           db.fetch('orig-1.jpg',
                    :width => 112,
                    :resize => false))
    assert(/w.102.orig-1.jpg/===
           db.fetch('orig-1.jpg',
                    :width => 102,
                    :resize => false))
  end

  def test_oe_le
    db = oe
    db.use_not_found = true
    db.not_found_image = 'notfound-1.jpg'
    assert(/orig-1.jpg/===
           db.fetch('orig-1.jpg',
                    :not_found => 'notfound-2.jpg'))
    assert !File.exists?(File.join(db.root,'w','102','orig-1.jpg'))
    assert(/w.102.orig-1.jpg/===
           db.fetch('orig-1.jpg',
                    :width => 102,
                    :not_found => 'notfound-2.jpg'))
    assert File.exists?(File.join(db.root,'w','102','orig-1.jpg'))
    assert(/w.102.orig-1.jpg/===
           db.fetch('orig-1.jpg',
                    :width => 102,
                    :not_found => 'notfound-2.jpg'))
    assert(/w.112.notfound-2.jpg/===
           db.fetch('orig-1.jpg',
                    :width => 112,
                    :resize => false,
                    :not_found => 'notfound-2.jpg'))
    assert(/w.102.orig-1.jpg/===
           db.fetch('orig-1.jpg',
                    :width => 102,
                    :resize => false,
                    :not_found => 'notfound-2.jpg'))
  end

  def test_oe_ln
    db = oe
    db.use_not_found = true
    db.not_found_image = 'notfound-1.jpg'
    assert(/orig-1.jpg/===
           db.fetch('orig-1.jpg',
                    :not_found => 'notfound-not-here.jpg'))
    assert !File.exists?(File.join(db.root,'w','102','orig-1.jpg'))
    assert(/w.102.orig-1.jpg/===
           db.fetch('orig-1.jpg',
                    :width => 102,
                    :not_found => 'notfound-not-here.jpg'))
    assert File.exists?(File.join(db.root,'w','102','orig-1.jpg'))
    assert(/w.102.orig-1.jpg/===
           db.fetch('orig-1.jpg',
                    :width => 102,
                    :not_found => 'notfound-not-here.jpg'))
    assert(/w.112.notfound-not-here.jpg/===
           db.fetch('orig-1.jpg',
                    :width => 112,
                    :resize => false,
                    :not_found => 'notfound-not-here.jpg'))
    assert(/w.102.orig-1.jpg/===
           db.fetch('orig-1.jpg',
                    :width => 102,
                    :resize => false,
                    :not_found => 'notfound-not-here.jpg'))
  end

  #--------------------------------------------------------------
  # original doesn't exist...

  def test_on_n
    db = oe
    assert_nil db.fetch('orig-not-here.jpg')
    assert_nil db.fetch('orig-not-here.jpg',:width => 102)
    assert_nil db.fetch('orig-not-here.jpg',:width => 102)
    assert_nil db.fetch('orig-not-here.jpg',:width => 112,:resize => false)
    assert_nil db.fetch('orig-not-here.jpg',:width => 102,:resize => false)
  end

  def test_on_ge
    db = oe
    db.use_not_found = true
    db.not_found_image = 'notfound-1.jpg'
    assert(/notfound-1.jpg/===db.fetch('orig-not-here.jpg'))
    assert(/w.102.notfound-1.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 102))
    assert File.exists?(File.join(db.root,'w','102','notfound-1.jpg'))
    assert(/w.102.notfound-1.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 102))
    assert(/w.112.notfound-1.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 112,
                    :resize => false))
    assert File.exists?(File.join(db.root,'w','112','notfound-1.jpg'))
      # File is created; :resize => false affects only request image
      # not the not-found image.
    assert(/w.102.notfound-1.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 102,
                    :resize => false))
  end

  def test_on_gn
    # We don't test for existence, as files don't exist...
    db = oe
    db.use_not_found = true
    db.not_found_image = 'notfound-not-here.jpg'
    assert(/notfound-not-here.jpg/===db.fetch('orig-not-here.jpg'))
    assert(/w.102.notfound-not-here.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 102))
    assert(/w.102.notfound-not-here.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 102))
    assert(/w.112.notfound-not-here.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 112,
                    :resize => false))
    assert(/w.102.notfound-not-here.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 102,
                    :resize => false))
  end

  def test_on_le
    db = oe
    db.use_not_found = true
    db.not_found_image = 'notfound-1.jpg'
    assert(/notfound-2.jpg/===
           db.fetch('orig-not-here.jpg',
                    :not_found => 'notfound-2.jpg'))
    assert(/notfound-2.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 102,
                    :not_found => 'notfound-2.jpg'))
    assert File.exists?(File.join(db.root,'w','102','notfound-2.jpg'))
    assert(/notfound-2.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 102,
                    :not_found => 'notfound-2.jpg'))
    assert(/notfound-2.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 112,
                    :resize => false,
                    :not_found => 'notfound-2.jpg'))
    assert File.exists?(File.join(db.root,'w','112','notfound-2.jpg'))
      # File is created; :resize => false affects only request image
      # not the not-found image.
    assert(/notfound-2.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 102,
                    :resize => false,
                    :not_found => 'notfound-2.jpg'))
  end

  def test_on_ln
    # We don't test for existence, as files don't exist...
    db = oe
    db.use_not_found = true
    db.not_found_image = 'notfound-1.jpg'
    assert(/notfound-not-here.jpg/===
           db.fetch('orig-not-here.jpg',
                    :not_found => 'notfound-not-here.jpg'))
    assert(/notfound-not-here.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 102,
                    :not_found => 'notfound-not-here.jpg'))
    assert(/notfound-not-here.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 102,
                    :not_found => 'notfound-not-here.jpg'))
    assert(/notfound-not-here.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 112,
                    :resize => false,
                    :not_found => 'notfound-not-here.jpg'))
    assert(/notfound-not-here.jpg/===
           db.fetch('orig-not-here.jpg',
                    :width => 102,
                    :resize => false,
                    :not_found => 'notfound-not-here.jpg'))
  end

  #--------------------------------------------------------------
  # sized exists...
  #
  # We probably don't need to do this, as we fetch sized in the above
  # tests.

  def se
    db = ITestUtils.newdb
    db.store(test_image1,:name => 'orig-1.jpg' )
    db.fetch('orig-1.jpg',:width => 102)
    db.store(test_image1,:name => 'notfound-1.jpg' )
    db.store(test_image1,:name => 'notfound-2.jpg' )
    db
  end

  def test_se_n; end
  def test_se_ge; end
  def test_se_gn; end
  def test_se_le; end
  def test_se_ln; end

  #--------------------------------------------------------------
  # sized doesn't exist...

  def test_sn_n; end
  def test_sn_ge; end
  def test_sn_gn; end
  def test_sn_le; end
  def test_sn_ln; end

end
