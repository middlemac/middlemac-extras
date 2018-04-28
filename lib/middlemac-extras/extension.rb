require 'middleman-core'
require 'pathname'
require 'fastimage'

################################################################################
# This extension provides Middleman several useful helpers and extends some of
# its built-in helpers to offer more features.
# @author Jim Derry <balthisar@gmail.com>
################################################################################
class MiddlemacExtras < ::Middleman::Extension

  ############################################################
  # Define the options that are to be set within `config.rb`
  # as extension options.
  ############################################################
  option :retina_srcset, true, 'If true then the image_tag helper will be extended to include automatic @2x images.'
  option :img_auto_extensions, true, 'If true then `image_tag` will work without filename extensions.'
  option :img_auto_extensions_order, %w(.svg .png .jpg .jpeg .gif .tiff .tif), 'Specifies the order to support automatic image extensions.'


  # @!group Extension Configuration

  # @!attribute [rw] options[:retina_srcset]=
  # This option determines whether or not the enhanced `image_tag` helper will
  # be used to include an @2x `srcset` attribute automatically. This automatic
  # behavior will only be applied if the image asset exists on disk and this
  # option is set to `true`.
  # @param [Boolean] value `true` or `false` to enable or disable this feature.
  # @return [Boolean] Returns the current value of this option.

  # @!attribute [rw] options[:img_auto_extensions]=
  # This option determines whether or not to support specifying images without
  # using a file name extension. If set to `true` then the `image_tag` helper
  # will work for images even if you don’t specify an extension, but only if a
  # file exists on disk that has one of the extensions in 
  # `:img_auto_extensions_order`.
  # @param [Boolean] value `true` or `false` to enable or disable this feature.
  # @return [Boolean] Returns the current value of this option.

  # @!attribute [rw] options[:img_auto_extensions_order]=
  # This option defines the eligible file name extensions and their precedence
  # when you specify an image without an extension using the `image_tag` helper.
  # Set this to an array of image file extensions in your desired order of
  # of precedence.
  # @param [Array<String>] value Set to an array of image extensions.
  # @return [Array<String>] Returns the current value of this option.

  # @!endgroup


  ############################################################
  # initialize
  # @visibility private
  ############################################################
  def initialize(app, options_hash={}, &block)

    super

    @md_links_b = nil
    @md_links_modern_b = nil
    @md_images_b = nil
    @md_sizes_b = nil

  end # initialize


  ############################################################
  # after_configuration
  #   Callback occurs before `before_build`.
  # @visibility private
  #############################################################
  def after_configuration

    # Reset the helpers' buffers when the configuration
    # changes. For speed we don't want to recalculate everything
    # every time a helper is used, but only the first time.
    @md_links_b = nil
    @md_links_modern_b = nil
    @md_images_b = nil
    @md_sizes_b = nil

  end


  ############################################################
  #  Helpers
  #    Methods defined in this helpers block are available in
  #    templates.
  ############################################################

  helpers do

    #--------------------------------------------------------
    # This helper provides access to `middlemac-extras`’ 
    # index of links in Markdown reference format, enabling
    # you to use reference-style links in documents. Because
    # this helper includes literal Markdown, it’s only useful
    # in Markdown documents.
    # @return [String] Returns a string with the Markdown
    #   index of every page in your project.
    #--------------------------------------------------------
    def md_links
      extensions[:MiddlemacExtras].md_links_b
    end


    #--------------------------------------------------------
    # This helper provides access to `middlemac-extras`’ 
    # index of links in Markdown reference format, enabling
    # you to use reference-style links in documents. Because
    # this helper includes literal Markdown, it’s only useful
    # in Markdown documents. This is only useful when using
    # Middlemac 3.0.0 or newer, which includes support for
    # helpbook style links.
    # @return [String] Returns a string with the Markdown
    #   index of every page in your project.
    #--------------------------------------------------------
    def md_hblinks
      extensions[:MiddlemacExtras].md_links_modern_b
    end


    #--------------------------------------------------------
    # This helper provides access to `middlemac-extras`’ 
    # index of images in Markdown reference format, enabling
    # you to use reference-style images in documents. Because
    # this helper includes literal Markdown, it’s only useful
    # in Markdown documents.
    # @return [String] Returns a string with the Markdown
    #   index of every image in your project.
    #--------------------------------------------------------
    def md_images
      extensions[:MiddlemacExtras].md_images_b
    end


    #--------------------------------------------------------
    # This helper provides CSS for every image in your
    # project. Each image will have a declaration that sets
    # `max-width` and `max-height` to the actual size of the
    # image. Proper @2x image support is included. It’s most
    # useful to use this helper in a `some_file.css.erb`
    # file.
    # @return [String] Returns a string with the CSS markup
    #   for every image found in your project.
    #--------------------------------------------------------
    def css_image_sizes
      extensions[:MiddlemacExtras].md_sizes_b
    end


    #--------------------------------------------------------
    # With the proper options enabled this helper extends
    # the built-in functionality of **Middleman**’s helpers
    # in a couple of ways. With `:retina_srcset` enabled,
    # automatic `srcset` attributes will be applied to
    # `<img>` tags if an @2x version of the specified image
    # is found. With `:img_auto_extensions` it’s possible to
    # specify image names without the file name extension.
    # @param [String] path Specify path to the image file.
    # @param [Hash] params Optional parameters to pass to
    #   the helper. **Middleman** (and other extensions)
    #   provide other parameters in addition to these.
    # @option params [Boolean] :img_auto_extensions Allows
    #   control of the automatic image extensions option
    #   on a per-use basis.
    # @option params [Boolean] :retina_srcset Allows control
    #   of the automatic @2x images feature on a per-use
    #   basis. 
    # @return [String] Returns an HTML `<img>` tag.
    # @group Extended Helpers
    #--------------------------------------------------------
    def image_tag(path, params={})
      params.symbolize_keys!
      ext_options = extensions[:MiddlemacExtras].options

      img_auto_extensions = ext_options[:img_auto_extensions]
      img_auto_extensions = params.delete(:img_auto_extensions) if params[:img_auto_extensions]
      
      middleman_targets = app.extensions[:MiddlemanTargets]

      retina_srcset = ext_options[:retina_srcset]
      retina_srcset = params.delete(:retina_srcset) if params[:retina_srcset]

      automatic_alt_tags = @app.extensions[:automatic_alt_tags]
      automatic_alt_tags = params.delete(:automatic_alt_tags) if params[:automatic_alt_tags]


      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Support images without extensions. If an image with the
      # specified name + :img_auto_extensions_order is found,
      # use that instead.
      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if File.extname(path) == '' && img_auto_extensions
        ext_options[:img_auto_extensions_order].reverse.each do |ext|
        
          original_path = path.dup
          proposed_path = app.extensions[:MiddlemacExtras].with_extension_proposal( original_path, ext )

          path = proposed_path if proposed_path != original_path

        end # each
        
        # If we're still empty and we're using `middleman-targets` let's try
        # to find a match using the `middleman-targets` gem, because there
        # may be a target-specific image but not the magic_word image that
        # was asked for.
        if File.extname(path) == '' && middleman_targets
          ext_options[:img_auto_extensions_order].reverse.each do |ext|
        
            test_path = "#{path}#{ext}"
            proposed_path = middleman_targets.target_specific_proposal(test_path)

            path = proposed_path if proposed_path != test_path

          end # each
          
        end # if
      end


      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Support automatic @2x image srcset.
      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if retina_srcset
        test_path = path.sub(/#{File.extname(path)}/i, "@2x#{File.extname(path)}")
        real_path = if path.start_with?('/')
                      File.expand_path(File.join(@app.config[:source], test_path))
                    else
                      File.expand_path(File.join(@app.config[:source], @app.config[:images_dir], test_path))
                    end

        file = app.files.find(:source, real_path)
        if file && file[:full_path].exist?
          params[:srcset] ||= "#{test_path} 2x"
        end
      end


      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Support automatic alt tags for absolute locations, too.
      # Only do this for absolute paths; let the extension do its
      # own thing otherwise.
      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if automatic_alt_tags && path.start_with?('/')
        alt_text = File.basename(path, '.*')
        alt_text.capitalize!
        params[:alt] ||= alt_text
      end


      super(path, params)
    end


  end #helpers



  ############################################################
  # Instance Methods
  # @!group Instance Methods
  ############################################################


  #########################################################
  # This accessor for @md_links_b lazily populates the
  # backing variable and buffers it for repeated use. In
  # the event of file changes, a server restart is needed.
  # @returns [String] Returns the Markdown reference list.
  # @!visibility private
  #########################################################
  def md_links_b
    unless @md_links_b
      @md_links_b = get_link_data('text/html', 'application/xhtml')
                        .collect { |l| 
                          if l[:title]
                            "[#{l[:reference]}]: #{l[:link]} \"#{l[:title]}\"" 
                          else
                            "[#{l[:reference]}]: #{l[:link]}" 
                          end
                          }
                        .join("\n")
    end

    @md_links_b
  end


  #########################################################
  # This accessor for @md_links_modern_b lazily populates
  # the backing variable and buffers it for repeated use.
  # In the event of file changes, a server restart is 
  # needed.
  # @returns [String] Returns the Markdown reference list.
  # @!visibility private
  #########################################################
  def md_links_modern_b
    unless @md_links_modern_b
      @md_links_modern_b = get_link_data('text/html', 'application/xhtml')
                          .collect { |l| 
                            if l[:title]
                              "[#{l[:reference]}]: #{l[:hb_link]} \"#{l[:title]}\"" 
                            else
                              "[#{l[:reference]}]: #{l[:hb_link]}" 
                            end
                            }
                          .join("\n")
    end

    @md_links_modern_b
  end


  #########################################################
  # This accessor for @md_images_b lazily populates the
  # backing variable and buffers it for repeated use. In
  # the event of file changes, a server restart is needed.
  # @returns [String] Returns the Markdown reference list.
  # @!visibility private
  #########################################################
  def md_images_b
    unless @md_images_b
      @md_images_b = get_link_data('image/')
                         .collect { |l| "[#{l[:reference]}]: #{l[:link]}" }
                         .join("\n")
    end
    @md_images_b
  end


  #########################################################
  # Get all of the required link data for generating
  # markdown shortcuts for the two property accessors.
  # @param [va_list<String>] types One or more MIME types
  #   specifying the file types for which to build links.
  # @return [Array<Hash>] An array of hashes containing
  #   the file data.
  # @!visibility private
  #########################################################
  def get_link_data( *types )
    all_links = []
    # We'll include a sort by number of path components in this chain so
    # that we can improve the chances of higher-level items not having
    # naming conflicts. For example, the topmost index.html file should
    # not require a prefix!
    app.sitemap.resources
        .select { |r| r.content_type && r.content_type.start_with?( *types ) }
        .sort { |a, b| Pathname(a.destination_path).each_filename.to_a.count <=> Pathname(b.destination_path).each_filename.to_a.count }
        .each do |r|
      reference_path = Pathname(r.destination_path).each_filename.to_a.reverse
      reference_path.shift
      reference = File.basename(r.destination_path, '.*').gsub(%r{ }, '_')
      link = r.url
      hb_link = defined?(r.hb_NavId) ? "#/#{r.hb_NavId}" : nil
      title = r.data.title ? r.data.title.gsub(%r{</?[^>]+?>}, '') : nil

      i = 0
      while all_links.find { |link| link[:reference] == reference }
        next_piece = reference_path[i].gsub(%r{ }, '_')
        reference = "#{next_piece}-#{reference}"
        i += 1
      end

      all_links << {:reference => reference, :link => link, :title => title, :hb_link => hb_link}
    end # .each

    all_links
  end


  #########################################################
  # For every image resource in the project, attempt to
  # build the CSS rules. Only bitmap images are supported,
  # as vectors (e.g., SVG) don’t have a specific size.
  # @returns [String] Returns the CSS stylesheet with the
  #   maximum width and height for each image.
  # @!visibility private
  #########################################################
  def md_sizes_b
    unless @md_sizes_b
      @md_sizes_b = []
      app.sitemap.resources
          .select { |r| r.content_type && r.content_type.start_with?('image/') }
          .each do |r|

        file = r.file_descriptor.full_path
        base_name = File.basename(r.destination_path, '.*')
        factor = 1
        factor = 2 if base_name.end_with?('@2x')
        factor = 3 if base_name.end_with?('@3x')
        if FastImage.size(file)
          width = (FastImage.size(file)[0] / factor).to_i.to_s
          height = (FastImage.size(file)[1] / factor).to_i.to_s
          # CSS matches string literals and doesn't evaluate image paths.
          # Assets in the image path with always bear the final path component
          # in order to avoid collisions while working with relative_assets or
          # not; items outside of the images_dir will use the basename only and
          # be subject to collisions.
          if r.url.start_with?("/#{app.config[:images_dir]}")
            subtract = "/#{app.config[:images_dir].split('/')[0...-1].join('/')}/"
            url = r.url.sub(subtract, '')
            @md_sizes_b << "img[src$='#{url}'] { max-width: #{width}px; max-height: #{height}px; }"
          else
            @md_sizes_b << "img[src$='#{File.basename(r.url)}'] { max-width: #{width}px; max-height: #{height}px; }"
          end
        end
      end # each
    end
    @md_sizes_b.join("\n")
  end
  
  
  #########################################################
  # Returns a file with an extension if found; otherwise
  # it returns the original file. This is used to search
  # for images for which no file name extension has been
  # provided.
  # @param [String] path Specifies the image without an
  #   extension, which is to be checked.
  # @param [String] ext Specifies the extension to check.
  # @returns [String] Returns the path of the image with
  #   an extension (if found), or returns the original
  #   `path` parameter.
  # @!visibility private
  #########################################################
  def with_extension_proposal( path, ext )
    return path unless File.extname(path) == '' && app.extensions[:MiddlemacExtras].options[:img_auto_extensions]
  
    real_path = path.dup

    # Enable absolute paths, too.
    real_path = if path.start_with?('/')
                  File.expand_path(File.join(app.config[:source], real_path))
                else
                  File.expand_path(File.join(app.config[:source], app.config[:images_dir], real_path))
                end

    proposed_path = "#{real_path}#{ext}"
    file = app.files.find(:source, proposed_path)
    
    if file && file[:full_path].exist?
      "#{path}#{ext}"
    else
      path
    end

  end


  #########################################################
  # Output colored messages using ANSI codes.
  # @param [String] message The message to output to the
  #   console.
  # @param [Symbol] color The color in which to display
  #   the message.
  # @returns [Void]
  # @!visibility private
  #########################################################
  def say(message = '', color = :reset)
    colors = { :blue   => "\033[34m",
               :cyan   => "\033[36m",
               :green  => "\033[32m",
               :red    => "\033[31m",
               :yellow => "\033[33m",
               :reset  => "\033[0m",
    }

    if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
      puts message
    else
      puts colors[color] + message + colors[:reset]
    end
  end # say


end # class MiddlemacExtras
