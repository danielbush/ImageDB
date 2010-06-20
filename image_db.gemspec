# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{image_db}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Bush"]
  s.date = %q{2010-06-21}
  s.description = %q{This package contains two components:

* ImageDb::DB is a simple ruby-based client or API for
  accessing and using an image database.
  Its primary purpose is to make handling different
  sized versions of the same image as easy as possible.
  It is both a way of storing these images in the filesystem
  and a simple wrapper for performing basic operations on them.
* ImageFile::Image defines an Image class that represents an image file.
  This can be run without ImageDb.
* For documentation on both of these build or check rdoc documentation
  or the source files (in lib/).}
  s.email = ["dlb.id.au@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt"]
  s.files = ["AUTHORS", "History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "image_db.gemspec", "lib/image_db.rb", "lib/image_db/db.rb", "lib/image_file.rb", "lib/image_file/image.rb", "script/console", "script/destroy", "script/generate", "test/test_data/backup/bogus_image.jpg", "test/test_data/backup/image with spaces in name.jpg", "test/test_data/backup/image-transparent.gif", "test/test_data/backup/image-transparent.png", "test/test_data/backup/image-transparent.xcf", "test/test_data/backup/image-w600-h400-300ppi.gif", "test/test_data/backup/image-w600-h400-300ppi.jpg", "test/test_data/backup/image-w600-h400-300ppi.png", "test/test_data/backup/image-w600-h400-72ppi.gif", "test/test_data/backup/image-w600-h400-72ppi.jpg", "test/test_data/backup/image-w600-h400-72ppi.png", "test/test_data/backup/image.xcf", "test/test_data/bogus_image.jpg", "test/test_data/image with spaces in name.jpg", "test/test_data/image-1.jpg", "test/test_data/image-2.jpg", "test/test_data/image-3.jpg", "test/test_data/image-4.jpg", "test/test_data/image-5.jpg", "test/test_data/image-6.jpg", "test/test_data/image-transparent.gif", "test/test_data/image-transparent.png", "test/test_data/image-transparent.xcf", "test/test_data/image-w600-h400-300ppi.jpg", "test/test_data/image-w600-h400-300ppi.png", "test/test_data/image-w600-h400-72ppi.gif", "test/test_data/image-w600-h400-72ppi.jpg", "test/test_data/image-w600-h400-72ppi.png", "test/test_data/image.xcf", "test/test_helper.rb", "test/test_image_db.rb", "test/testutils.rb"]
  s.homepage = %q{http://github.com/danielbush}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{image_db}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{This package contains two components:  * ImageDb::DB is a simple ruby-based client or API for accessing and using an image database}
  s.test_files = ["test/test_image_db.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<hoe>, [">= 2.6.0"])
    else
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<hoe>, [">= 2.6.0"])
    end
  else
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<hoe>, [">= 2.6.0"])
  end
end
