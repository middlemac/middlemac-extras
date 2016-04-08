################################################################################
# extension.rb
#  This file constitutes the framework for the bulk of this extension.
################################################################################
require 'middleman-core'
require 'pathname'
require 'fastimage'

class MiddlemacExtras < ::Middleman::Extension

  ############################################################
  # Define the options that are to be set within `config.rb`
  # as extension options.
  ############################################################
  option :retina_srcset, true, 'If true then the image_tag helper will be extended to include automatic @2x images.'
  option :img_auto_extensions, true, 'If true then `image_tag` will work without filename extensions.'
  option :img_auto_extensions_order, %w(.svg .png .jpg .jpeg .gif .tiff .tif), 'Specifies the order to support automatic image extensions.'


  ############################################################
  # initialize
  ############################################################
  def initialize(app, options_hash={}, &block)

    super

    @md_links_b = nil
    @md_images_b = nil
    @md_sizes_b = nil

  end # initialize


  ############################################################
  # after_configuration
  #  Callback occurs before `before_build`.
  #############################################################
  def after_configuration

    # Reset the helpers' buffers when the configuration
    # changes. For speed we don't want to recalculate everything
    # every time a helper is used, but only the first time.
    @md_links_b = nil
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
    # md_links
    #   Adds simple markdown links where needed.
    #--------------------------------------------------------
    def md_links
      extensions[:MiddlemacExtras].md_links_b
    end


    #--------------------------------------------------------
    # md_images
    #   Adds simple markdown image links where needed.
    #--------------------------------------------------------
    def md_images
      extensions[:MiddlemacExtras].md_images_b
    end


    #--------------------------------------------------------
    # css_image_sizes
    #   Generates image size CSS information for all images.
    #--------------------------------------------------------
    def css_image_sizes
      extensions[:MiddlemacExtras].md_sizes_b
    end


    #--------------------------------------------------------
    # image_tag(path, params={})
    #   Add automatic srcset if an @2x image is present and
    #   no srcset is already specified. Also support the
    #   use of extension-less images.
    #--------------------------------------------------------
    def image_tag(path, params={})
      params.symbolize_keys!
      ext_options = extensions[:MiddlemacExtras].options

      img_auto_extensions = ext_options[:img_auto_extensions]
      img_auto_extensions = params.delete(:img_auto_extensions) if params[:img_auto_extensions]

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
          real_path = "#{path.dup}#{ext}"
          real_path = if path.start_with?('/')
                        File.expand_path(File.join(@app.config[:source], real_path))
                      else
                        File.expand_path(File.join(@app.config[:source], @app.config[:images_dir], real_path))
                      end

          file = app.files.find(:source, real_path)
          if file && file[:full_path].exist?
            path = "#{path.dup}#{ext}"
          end
        end # each
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
  #  Instance Methods
  ############################################################

  #--------------------------------------------------------
  # md_links_b
  #   Adds simple markdown links where needed.
  #--------------------------------------------------------
  def md_links_b
    unless @md_links_b
      @md_links_b = get_link_data('text/html', 'application/xhtml')
                        .collect { |l| "[#{l[:reference]}]: #{l[:link]} \"#{l[:title]}\"" }
                        .join("\n")
    end

    @md_links_b
  end


  #--------------------------------------------------------
  # md_images_b
  #--------------------------------------------------------
  def md_images_b
    unless @md_images_b
      @md_images_b = get_link_data('image/')
                         .collect { |l| "[#{l[:reference]}]: #{l[:link]}" }
                         .join("\n")
    end
    @md_images_b
  end


  #--------------------------------------------------------
  # get_link_data( *types )
  #   Get all of the required link data for generating
  #   markdown shortcuts.
  # @param  types should be the content_type to check.
  # @return an array of hashes with file data.
  #--------------------------------------------------------
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
      title = r.data.title ? r.data.title.gsub(%r{</?[^>]+?>}, '') : nil

      i = 0
      while all_links.find { |link| link[:reference] == reference }
        next_piece = reference_path[i].gsub(%r{ }, '_')
        reference = "#{next_piece}-#{reference}"
        i += 1
      end

      all_links << {:reference => reference, :link => link, :title => title}
    end # .each

    all_links
  end


  #--------------------------------------------------------
  # md_sizes_b
  #  For every image resource, try to build the size.
  #--------------------------------------------------------
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
  end

end # class MiddlemacExtras
