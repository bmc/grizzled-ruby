#                                                                -*- ruby -*-

Gem::Specification.new do |s|

  s.name             = 'grizzled-ruby'
  s.version          = '0.1.4'
  s.date             = '2011-03-25'
  s.summary          = 'Some general-purpose Ruby modules, classes, and tools'
  s.authors          = ['Brian M. Clapper']
  s.license          = 'BSD'
  s.email            = 'bmc@clapper.org'
  s.homepage         = 'http://software.clapper.org/grizzled-ruby'
  s.has_rdoc         = true

  s.description      = <<-ENDDESC
Grizzled Ruby is a general purpose library of Ruby modules, classes and tools.
ENDDESC

  s.require_paths    = ['lib']

  # = MANIFEST =
  s.files            = Dir.glob('[A-Z]*')
  s.files           += Dir.glob('*.gemspec')
  s.files           += Dir.glob('lib/**/*')
  s.files           += Dir.glob('rdoc/**/*')


  # = MANIFEST =
  s.test_files       = FileList['test/**/tc_*.rb'].to_a
end


