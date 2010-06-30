# This file is part of ImageDB, a ruby-based image handling program.
# Copyright (C) 2010 Daniel Bush
# This program is distributed under the terms of the MIT License.
# See the README.rdoc file for details.


module DLBImageUtils
module ImageFile

  class Image

    attr_reader :width
    attr_reader :height
    attr_reader :name
      # Filename of image
    attr_reader :filename
      # Full path to image

    attr_accessor :convert
    attr_accessor :identify

    # Create a new Image instance.
    #
    # You should supply a valid file name.

    def initialize filename

      raise "File '#{filename}' doesn't exist." unless FileTest.file? filename

      # Get external convert and identify binaries here.
      #
      # If we were to implement rmagick we'd have to start
      # here and change stuff...

      @convert,@identify = ImageFile::check_libs

      @filename=filename
      @name=File.basename(@filename)

      # Get dimensions:
      result=%x{#{@identify} '#{@filename}' 2>&1}
      status=$?
      raise result unless status==0
      size_spec=result.split(' ')[2]
      dimensions=size_spec.split('x')
      @width=dimensions[0].to_i
      @height=dimensions[1].to_i

    end

    # Create blank file will image size stored in image name
    #
    # This was one approach to caching image size information.
    # I'm not recommending this necessarily.

    def create_size_record
      record="#{@filename}-#{@width}x#{@height}.size"
      FileUtils.touch record
      record
    end

    # Convert an image according to settings in +params+ hash.
    # 
    # Available options:
    # +to+:: the output image name.  Extension on the file name will
    # be used to determine the output format of the image.
    # +height+:: scale image by its height; maintain ratio
    # +width+:: scale image by its width; maintain ratio

    def out params
      raise "Missing argument 'to'." unless params.has_key?(:to)
      to=params[:to]
      raise "Bad argument 'to':'#{to}'" unless /\.jpg$|\.jpeg$|\.gif$|\.png$/i===to

      if height=params[:height]
        if height.to_i>=@height
          result=%x{cp #{@filename} #{to} 2>&1}
          status=$?
        else
          result=%x{#{@convert} -colorspace RGB -scale x#{height} #{@filename} #{to} 2>&1}
          status=$?
        end
      elsif width=params[:width]
        if width.to_i>=@width
          result=%x{cp #{@filename} #{to} 2>&1}
          status=$?
        else
          result=%x{#{@convert} -colorspace RGB -scale #{width} #{@filename} #{to} 2>&1}
          status=$?
        end
      else
        #raise "Did not supply :height or :width spec."
        result=%x{#{@convert} -colorspace RGB #{@filename} #{to} 2>&1}
        status=$?
      end
      raise result unless status==0
    end

  end



end
end

