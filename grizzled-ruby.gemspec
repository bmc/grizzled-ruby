#                                                                -*- ruby -*-

Gem::Specification.new do |spec|

  require 'rake'  # for FileList

  spec.rubygems_version = '1.3.5'

  spec.name             = 'grizzled-ruby'
  spec.version          = '0.1.0'
  spec.date             = '2011-03-12'

  spec.summary          = 'Miscellaneous, general-purpose Ruby modules and ' +
                          'classes'
  spec.description      = 'grizzled-ruby is a general purpose library of ' +
                          'Ruby modules and classes'

  spec.authors          = ['Brian M. Clapper']
  spec.email            = 'bmc@clapper.org'
  spec.homepage         = 'http://github.com/bmc/grizzled-ruby'

  # = MANIFEST =
  spec.files            = FileList['lib/**/*.rb'].to_a
end


