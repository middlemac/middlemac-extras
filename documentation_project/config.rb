################################################################################
# Sample Project for middlemac-extras
################################################################################

#==========================================================================
# Conflicting resources
#  middlemac-extras uses Middleman's resource map to generate a lot of the
#  information that it provides. Be sure to activate other extensions that
#  might manipulate the resource map before activating middlemac-extras,
#  such as MiddlemanPageGroups.
#
#  The `image_tag` helper should inherit from other `image_tag` helpers,
#  so it's best to make sure they're activated first.
#==========================================================================
# activate :MiddlemanPageGroups
activate :automatic_alt_tags

#==========================================================================
# Extension Setup
#==========================================================================
activate :MiddlemacExtras do |config|

  # If set to true, then the enhanced image_tag helper will be used
  # to include @2x srcset automatically, if the image asset exists.
  config.retina_srcset = true

  # If set to true then the `image_tag` helper will work for images even
  # if you don't specify an extension, but only if a file exists on disk
  # that has one of the extensions in :img_auto_extensions_order.
  config.img_auto_extensions = true

  # Set this to an array of extensions in the order of precedence for
  # using `image_tag` without file extensions.
  config.img_auto_extensions_order = %w(.svg .png .jpg .jpeg .gif .tiff .tif)
  
end


#==========================================================================
# Regular Middleman Setup
#==========================================================================

set :relative_links, true
activate :syntax


#==========================================================================
# Helpers
#  These helpers are used by the sample project only; there's no need
#  to keep them around in your own projects.
#==========================================================================

# Methods defined in the helpers block are available in templates
helpers do

  def product_name
    'middlemac-extras'
  end

  def product_version
    '1.0.8'
  end

end

# Build-specific configuration
configure :build do
  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript
end
