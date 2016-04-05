require 'middleman-core'

Middleman::Extensions.register :MiddlemacExtras, :before_configuration do
  require_relative 'middlemac-extras/extension'
  MiddlemacExtras
end
