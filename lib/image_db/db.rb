# This file is part of ImageDB, a ruby-based image handling program.
# Copyright (C) 2010 Daniel Bush
# This program is distributed under the terms of the MIT License.
# See the README.rdoc file for details.

module ImageDb

  Image = ImageFile::Image
  FileSeparator = File.join('','')

# = Image DB
# 
# ImageDb is a simple ruby-based client or API for
# accessing and using an image database.
# 
# Its primary purpose is to make handling different
# sized versions of the same image as easy as possible.
#
# == Features
# 
# * the image databse (db) is filesystem-based (ie hierarchical)
# * the db has a root directory
# * images are stored as normal files under the root directory
#   in various folders
# * multiple copies of the image can be retrieved and stored
#   based on differences in width or height
# * sized images can be autogenerated
# * the db does not handle or is not aware of image ppi
# * the intention is to use it to store web-ready images which are
#   usually 72-96 ppi and to be accessed from a web framework such as
#   rails
# * the db treats an image with same name other than its format (.png,.jpg etc)
#   as a different image
# * dimensions are always specified in pixels
# * names in the db should probably be composed of
#   letters, numbers, hyphens and underscores
#
# === Original vs Sized Images
#
# * the db "thinks" of an image as a set of images where each
#   member in that set, whilst depicting the same thing, is different in
#   dimension.
#   There are 2 parts to the model:
#   * original image - this is the original image that you store in the
#     db.  
#   * sized/derivative images - these are images generated off of the
#     original image; DB makes it fairly easy to do this
# * if you have lots of images with the same name but
#   depicting something different, consider
#   prepending a category into the name like so:
#     imageA.png => cat1-imageA.png
#                => cat2-imageA.png
#  
# === Groups
#
# * you can optionally specify a group name when storing an image
#   * this creates a group within the db
#   * the group is a new db and corresponds to a subdirectory of the
#     parent db
#   * when retrieving an image from a group you will need to specify
#     the group name (see further down)
#  
# === Autogeneration of sized images
#
# * if you fetch an image which exists but not at the specified
#   dimension, the db will automatically create it for you
#   unless you specify not to
#
# === Hooks
#
# * hooks are called during major operations; this
#   might allow you to update your database etc
#   * if the hook fails, the operation is NOT rolled back
#   * if the operation fails, the hook will probably not get called
#   * this behaviour will be considered if ImageDB matures; remember
#     that ImageDB is just an experiment - a simple wrapper around
#     a file system
# 
# 
# === ImageDb FORMAT
# 
# * the format of the filesystem under the root directory is
#   straightforward and easy to navigate manually
# * the image you store is copied to an originals section so
#   you can use it to resize
# 
#     root := /path/to/root  # Location of db in filesystem
#     DB := [root]/originals/[name]  # Original image files
#                 /groups/[group]    # Groups for sub-db's
#                 /w/[width]/[name]  # Width-resized images
#                 /h/[height]/[name] # Height-resized images
#     group := [group-name]/[DB]     # Recursive DB
# 
# In other words:
# * your image db is at /path/to/root
# * original images are stored in originals/[name]
# * images resized according to width are stored in w/[width]/[name]
# * images resized according to height are stored in h/[height]/[name]
# * groups are stored in groups/
# * an group is defined like the above where
#   root is now groups/[group-name]
# 
# == USAGE:
# 
# * the db will raise an error if you try to store an image with
#   the same name unless you specify a force option
#   * this is to prevent possibility of having you load a different
#     depiction into the db
#   * if you do force, consider updating resized images
# * the db will return nil if you try to fetch an image that doesn't exist  
# * the extension of the file name (.jpg,.png) is considered part of
#   the name so it must be included in all relevant operations
# 
# === STARTING
# 
#   name = '/path/to/root'
#   db = ImageDb::DB.new(name)
# 
# 
# === STORING
# 
#   db.store('/path/to/image.jpg')
#     => "/db-root/path/to/image.jpg"  # Path will be in db.root.
#     => error if exists
#   db.store('/path/to/image.jpg',:force => true)
#     => "/db-root/path/to/name" # Overrides existing
#   db['group1'].store('/path/to/image.jpg')
#     => "/db-root/path/to/groups/group1/image.jpg"
# 
# 
# === FETCHING
# 
# * Fetch an image (original or sized) from the db
# * 'name' is the image name; do not include any path
# * if a sized image being fetched doesn't exist it will be
#   autogenerated
# * Fetching retrieves a string of the file path
#
#     db.fetch(name)
#       => fetches original image
#       => nil if not there
#       => "/db.root/path/to/image"
#     
#     db.fetch(name,:width => 60)
#     db.fetch(name,:height => 60)
#       => fetches sized image; autogenerates it if necessary
#       => "/db.root/path/to/w/60/image"
# 
#     db.fetch(name,:height => 60,:exists => true)
#       => Don't autogenerate if image doesn't exist
# 
#     db['group1'].fetch(name,:width => 60)
#       => Fetch image from group1
#       => nil if image or group don't exist
# 
# === NOT FOUND IMAGES
# 
# * Set DB#use_not_found=true
# * You can specify a not found image to use when fetching images
#   that don't exist (instead of returning nil)
# * You can also specify a not found image as a param option when
#   fetching an image
# * Your not-found image should be an existing image in the db and
#   will be auto-resized as required (like other images)
# 
# === RESOLVING
# 
# * Often, the db's root is exposed via http.
# * In these cases, you might want the db to return a file location
#   relative to the http server's public root or alias.
#   * your alias or server root should point to the actual root of
#     the db
# * specify the resolving root as a second argument when creating db
#
#     root = '/var/www/site1/public/images/db'
#     rel_root = '/images/db'
#     db = ImageDb::DB.new(root,rel_root)
#     ...
# 
#     src = db.fetch(image_name)
#        => '/images/db/.../image-1.jpg'
#     src = db.fetch(image_name,:absolute => true)
#        => '/var/www/.../image-1.jpg'
# 
# === UPDATING
# 
# * Force all sized images to be recreated from the original image
#   (fetching will only autogenerate, not regenerate)
#
#     db.update(name)
#       => updates all sized images of the original
# 
#     db.update(name,:width => w)
#     db.update(name,:height => h)
#       => resize particular width or height
# 
# === DELETING
# 
# * Manually delete but beware if there are other systems
#   relying on image db
# * Or, use the api:
#
#     db.delete(name)
#     db['group1'].delete(name)
#       => nil
# 
# === LISTING
# 
# * Listing is useful when you want to display several or all images
#   in the db
# 
# * List all original images excluding groups
#
#     db.images => ['/path/to/image1',...]
# 
# * List all images belonging to name - including all sizes
#   * Used internally to delete an image from the db
#   * the original is always listed first
#
#     original,*others = db.image(name) => ['/path/to/image1',...]
# 
# * If you want to see all images of a certain size
#
#     db.all(:width => 300)
#       => ['/path/to/w/300/image1',...]
# 
#     db['group1'].all(:width => 300)
#       => ['/path/to/w/300/image1',...]
# 
# * List all original images in a group
#
#     db['group1'].images => ['/path/to/image1',...]
# 
# * List all groups
#
#     db.groups => ['group1',...]
# 
# 
# === HOOKS
# 
# * Hooks are intended to allows you to be notified when a
#   change is made to an image in the db
#   * original image is created
#   * original image is replaced by a new one
#     using the :force option with 'store'
#   * existing image is modified
#   * a fetched image is autogenerated
# * You have to create an object that responds to the supported hooks
#   to be executed
# * Pass this in to image db when you start it
# * methods on this object will be passed relevant information
#   pertaining to the event
# * supported hooks
#   * create
#     * params
#       * :force => true|nil
#       * :original => '/path/to/file'
#       * :sized => '/path/to/.../file' or ['/path/to/.../file',...]
#         * if not given, then a sized image was not created
#       * :autogenerated => true|false
#         * only added if :sized is
#       * :width|:height => 300
#         * only added if :sized is
#   * delete
#     * params
#       * :original => '/path/to/file'
#       * :sized => ... or [...]
#
# Example:
#
#   class ImageDBHooks
#     def create params
#       ...
#     end
#     ...
#   end
#   db = ImageDb::DB.new('/path/to/root')
#   db.hooks = ImageDBHooks.new
# 

  class DB

    attr_reader :root,:rel_root,:originals,:parent_db
    attr_accessor :hooks
    attr_writer :not_found_image
    attr_accessor :use_not_found

    # Return not_found_image in this db or nearest parent db.
    #
    # You can override this setting using params[:not_found] in fetch.

    def not_found_image
      return @not_found_image if @not_found_image
      return self.parent_db.not_found_image if self.parent_db
      return nil
    end

    def initialize root,rel_root=nil,parent_db=nil
      @root = root
      @rel_root = rel_root.nil? ? root : rel_root
      @mutex = Mutex.new
      @hooks = nil
      @parent_db = parent_db
      @not_found_image = nil

      # Stores groups which are instances of DB
      @groups = Hash.new

      # Make root if it doesn't exist
      @originals = File.join(@root,'originals')
      @w = File.join(@root,'w')
      @h = File.join(@root,'h')

      FileUtils.mkdir_p @originals
      FileUtils.mkdir_p @w
      FileUtils.mkdir_p @h
    end

    #------------------------------------------------------------
    # Resolving...


    # Resolve an image name relative to root or rel_root.
    # A string location is always returned.
    #
    # * params are tested for :width or :height; only
    #   one should be supplied
    # * if params is nil, resolve the original name
    # * resolve and absolute do not care about image existence;
    #   they are only concerned with resolving the location
    #   of the image if it were in the db (whether it is or not)

    def resolve nm,params=nil
      return nil if nm.nil?
      root = @root
      root = @rel_root unless params && params[:absolute]
      if params.nil?
        File.join(root,'originals',File.basename(nm))
      elsif params[:width]
        File.join(root,'w',params[:width].to_s,File.basename(nm))
      elsif params[:height]
        File.join(root,'h',params[:height].to_s,File.basename(nm))
      else
        File.join(root,'originals',File.basename(nm))
      end
    end

    # Resolve names absolutely using root not rel_root.
    # A string location is always returned.
    #
    # * Useful for performing real filesystem operations
    # * See resolve

    def absolute nm,params=nil
      n = nil
      params ||= {}
      params[:absolute] = true
      n = resolve nm,params
      return n
    end


    #------------------------------------------------------------
    # CRUD operations


    # Store an original image
    #
    # This is the only way new images can be stored in the
    # db.  'path' should be a filepath to a real image.
    # You can specify an alternative image name to the 'path'
    # using options[:name]
    #   store '/path/to/image.jpg' , :name => 'image-2.jpg'

    def store path,options=nil
      name = options && options[:name] ? options[:name] : File.basename(path)
      nm = File.join(@originals,name)
      if File.exists?(nm)
        raise 'Error #1 '+@@errors[1] if options.nil? || !options[:force]
      end
      FileUtils.copy path , nm
      @hooks.create(:force => (options.nil? ? nil : options[:force]) ,
                    :original => nm) if @hooks
      nm
    end

    # Rename an image in the db to a new name including all its sized
    # versions.
    #
    # Use params[:force]=true to force writing over an image.

    def rename old,new,params=nil
      a = self.image(old)
      return nil if a.nil?
      b = self.image(new)
      if !b.nil?
        raise 'Error #3 ' + @@errors[3] if !params || !params[:force]
        delete b[:original]
      end
      self.store absolute(a[:original]),:name => new
      a[:widths].each do |w|
        self.fetch new , :width => w
      end
      a[:heights].each do |w|
        self.fetch new , :height => w
      end
      delete a[:original]
    end

    # Fetch an image (original or sized)
    #
    # Returns string location of image or nil if the original
    # does not exist in the db.  If you are fetching a sized
    # image of an existing original which doesn't exist, it
    # will be autogenerated from the original.
    #
    # == Params
    # * width or height: specify desired width or height of image.
    #                    Omitting this will return the original.
    # * absolute: return the file path; do not resolve to rel_root
    # * not_found: specify a not_found image; in general set this using
    #              DB#not_found_image but override here if you want to
    # * exists: do not autogenerate image; this is how to test for existence
    # * skiphook: skip running creation hook
    # * update: force image generation even if it exists; used by 'update'

    def fetch name,params=nil

      o = absolute(name) # Original
      n = nil

      # Find not_found image...
      nf = (params && params.has_key?(:not_found) ?
                     params[:not_found] : self.not_found_image)

      # Original doesn't exist, use nf...

      if !File.exists?(o) && self.use_not_found
        name = nf
        o = absolute(name)
      end

      return nil if name.nil?

      # Fetch original...

      if params.nil?
        return resolve(name) if File.exists?(o)
        return nil
      end

      raise "fetch: Invalid options" if !params.has_key?(:width) &&
        !params.has_key?(:height) &&
        !params.has_key?(:absolute) &&
        !params.has_key?(:not_found)

      n = absolute(name,params) # Sized or original
      FileUtils.mkdir_p File.dirname(n)

      # Autogenerate/regenerate/do-nothing on sized image (n)
      # depending on settings...

      if File.exists?(n)
        unless params[:update]
          return absolute(name,params) if params[:absolute]
          return resolve(name,params)
        end
      else
        if params[:exists]==true
          # Slightly ugly.  We have an original, but this size
          # doesn't exist.  We revert back to the not found image.
          if self.use_not_found
            return absolute(nf,params) if params[:absolute]
            return resolve(nf,params)
          end
          return nil
        end
        autogenerated = true
      end

      i = Image.new(o)
      params[:to] = n
      i.out params
      @hooks.create(:original => o,
                    :sized => n,
                    :autogenerated => autogenerated,
                    :width => params[:width],
                    :height => params[:height]) if @hooks && !params[:skiphook]
      return absolute(name,params) if params[:absolute]
      return resolve(name,params)
    end


    # Resize or create sized versions of an image.
    # If params are nil, then update all sized images for
    # specified image.

    def update name,params=nil
      options = {
        :update => true,   # Force update even if it exists
        :exists => false,  # Don't autogenerate
        :skiphook => true  # Don't run hooks
      }

      # Update all sized instances of an original:
      if params.nil?
        r = self.image(name)
        return if r.nil?
        original = resolve(r[:original])
        others  = r[:widths].collect{|w|
          self.fetch(name,options.merge(:width => w))}
        others += r[:heights].collect{|h|
          self.fetch(name,options.merge(:height => h))}
        @hooks.create(:original => original,
                      :sized => others,
                      :update => true) if @hooks
        return original

      # Update single sized image:
      else
        nm = fetch(name,params.merge(options))
        @hooks.create(:sized => nm,
                      :update => true) if @hooks
        return nm
      end
    end

    # Delete original and all its derivatives or
    # if params are given, delete a selected sized image 

    def delete name,params=nil
      images = self.image(name)
      return nil if images.nil?
      o = absolute(images[:original])

      if params.nil?
        File.delete(o) if File.exists?(o)
        [:widths,:heights].each do |w|
          images[w].each do |i|
            File.delete(absolute(name,
                                 (w==:widths ? :width : :height) => i))
          end
        end
        @hooks.delete(:original => images[:original],
                      :sized => images[:widths]+images[:heights]) if @hooks
        return o

      else
        w,h = params[:width],params[:height]
        n = nil
        if w
          n = absolute(name,:width => w)
          File.delete(n)
          @hooks.delete(:sized => [n]) if @hooks
        elsif h
          n = absolute(name,:height => h)
          File.delete(n)
          @hooks.delete(:sized => [n]) if @hooks
        else
          raise 'Error #2 '+@@errors[2]
        end
        return n

      end
    end

    #---------------------------------------------------------
    # Listing / Querying

    # List original images (excluding groups).
    # Paths are not returned so you need to use fetch().
    #
    # Returns an array.
    # Use images.grep(/search-pattern/) to search for originals.
    # Also see glob.

    def images
      r = nil
      Dir.chdir(@originals) do
        r = Dir['*']
      end
      return r
    end

    # List all (sized) images for an image.
    # Paths are not returned so you need to use fetch().
    #
    # Returns { :original => name ,
    #           :widths => [60,...] ,
    #           :heights => [135,...]
    #         }
    #         or nil if original doesn't exist

    def image name
      n = absolute(name)
      return nil unless File.exists?(n)
      result = {}
      result[:original] = name
      l = lambda do |w|
        r = []
        Dir.chdir(w) do
          Dir['*'].each do |d|
            if File.directory?(d)
              nm = File.join(w,d,name)
              r.push(d.to_i) if File.exists?(nm)
            end
          end
        end
        r
      end
      result[:widths] = l.call(@w)
      result[:heights] = l.call(@h)
      result
    end

    # Use shell wildcard style searching (simpler than regex).
    #
    # Returns image name.  Use fetch to fetch it.

    def glob pattern
      Dir[File.join(@originals,pattern)].collect do |f|
        File.basename(f)
      end
    end

    #---------------------------------------------------------
    # Groups

    # List groups in DB

    def groups
      g = File.join(@root,'groups')
      FileUtils.mkdir_p g
      Dir.chdir(File.join(@root,'groups')) do
        Dir['*']
      end
    end

    # Access a group to perform DB operations on that group.

    def [] name
      @groups ||= {}
      root = File.join(@root,'groups',name)
      rel_root = @rel_root.nil? ? root : File.join(@rel_root,'groups',name)
      FileUtils.mkdir_p(root)
      return @groups[name] if @groups[name]
      db = DB.new(root,rel_root,self)
      db.use_not_found = self.use_not_found
      return (@groups[name] = db)
    end

    @@errors = {
      1 => 'Image already exists; use force to replace it',
      # It's possible you are trying to store an image with
      # the same name that depicts something totally different.
      # If this is so, set the force option and clear out all
      # copies of the older image.
      2 => 'Params should be nil or contain either :width or :height but not both' ,
      3 => 'Image exists.  You are trying to replace it with another one.  Use the force option.' 
    }

  end

end
