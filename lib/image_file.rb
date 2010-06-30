# This file is part of ImageDB, a ruby-based image handling program.
# Copyright (C) 2010 Daniel Bush
# This program is distributed under the terms of the MIT License.
# See the README.rdoc file for details.

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# = ImageFile Module
# 
# * http://github.com/danielbush
# * project has not been added to github just yet
# 
# == DESCRIPTION:
# 
# A module that contains an ImageFile class that represents an
# image file.
# This module can be used by itself, but one of its main purposes
# is to support image_db.
# 
# * The image file object represents an image file for the purposes of
#   resizing, obtaining image dimensions, or changing format (png->jpg etc)
# * relies on imagemagick
# * Because of problems I've had running rmagick within ruby
#   this representation calls imagemagick binaries as
#   external processes.
# * However, it should be fairly simple to swap out the 
#   external process implementation with one that uses rmagick.
# * This library is intended as a simple wrapper perhaps for
#   multiple implementations
# 
# == FEATURES/PROBLEMS:
# 
# * Needs a native rmagick implementation for people who have
#   this working.
# * A mechanism for switching implementations
# 
# == SYNOPSIS:
# 
#   i=Image.new(image_filename)
#   i.width
#   i.height
#   i.out :to => '/path/to/new_name.png' , :width => 140
#   i.out :to => '/path/to/new_name.jpg' , :height => 40
#   i.out :to => '/path/to/new_name.jpg' 
# 
# 


module DLBImageUtils

module ImageFile

  TESTDIR = File.join(File.dirname(__FILE__) , '..' , 'test' , 'test_data')
    # Location of test images for you to play with and for use in tests.

  # List test images
  
  def self.test_images
    Dir[File.join(TESTDIR,'*')]
  end

  # Retrieve a test image as Image object.

  def self.test_image name
    nm = File.join(File.expand_path(TESTDIR),name)
    #return ImageFile::Image.new(nm) if File.exists?(nm)
    return nm if File.exists?(nm)
  end

  # Check we have required binaries to do the job of processing
  # images.
  #
  # This assumes we are using the "external" implementation of
  # imagemagick - see README on this.

  def self.check_libs
    if File.exists? '/usr/local/bin/convert'
      convert='/usr/local/bin/convert'
    elsif File.exists? '/usr/bin/convert'
      convert='/usr/bin/convert'
    else
      raise "Can't find 'convert' binary."
    end
    if File.exists? '/usr/local/bin/identify'
      identify='/usr/local/bin/identify'
    elsif File.exists? '/usr/bin/identify'
      identify='/usr/bin/identify'
    else
      raise  "Can't find 'identify' binary."
    end
    [convert,identify]
  end

end
end

require 'image_file/image'


