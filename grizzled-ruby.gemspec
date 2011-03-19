#                                                                -*- ruby -*-

Gem::Specification.new do |spec|

  spec.name             = 'grizzled-ruby'
  spec.version          = '0.1.2'
  spec.date             = '2011-03-19'

  spec.summary          = 'Miscellaneous, general-purpose Ruby modules and ' +
                          'classes'
  spec.description      = <<-ENDDESC
Grizzled Ruby is a general purpose library of Ruby modules and classes.
ENDDESC

  spec.authors          = ['Brian M. Clapper']
  spec.email            = 'bmc@clapper.org'
  spec.homepage         = 'http://software.clapper.org/grizzled-ruby'

  spec.require_paths    = ['lib']
  spec.files            = Dir['lib/**/*.rb']
end


