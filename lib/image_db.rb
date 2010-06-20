# This file is part of ImageDB, a ruby-based image handling program.
# Copyright (C) 2010 Daniel Bush
# This program is distributed under the terms of the MIT License.
# See the README.rdoc file for details.

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module ImageDb
  VERSION = '0.0.1'
end

require 'fileutils'
require 'image_file'
require 'image_db/db'
