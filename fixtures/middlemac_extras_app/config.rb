activate :MiddlemacExtras do |config|
  config.retina_srcset = true
  config.img_auto_extensions = true
  config.img_auto_extensions_order = %w(.svg .png .jpg .jpeg .gif .tiff .tif)
end

set :relative_links, true
