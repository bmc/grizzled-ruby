#                                                                  -*- ruby -*-

require 'rake/clean'

PACKAGE = 'grizzled-ruby'
GEMSPEC = "#{PACKAGE}.gemspec"
DOC_OUTPUT_DIR = '../gh-pages/rdoc'
RUBY_FILES = FileList['**/*.rb']

def load_gem(spec)
  eval File.open(spec).readlines.join('')
end

def gem_name(spec)
  gem = load_gem(spec)
  "#{PACKAGE}-#{gem.version.to_s}.gem"
end

GEM = gem_name(GEMSPEC)
CLEAN << GEM

task :default => :build

task :build => [:gem, :doc]

task :gem => GEM

task :doc => RUBY_FILES do |t|
  require 'rdoc/rdoc'
  puts('Running rdoc...')
  r = RDoc::RDoc.new
  r.document(['-o', DOC_OUTPUT_DIR, 'lib'])
end

task :install => :gem do |t|
  sh "gem install #{GEM}"
end

file GEM => RUBY_FILES + ['Rakefile', GEMSPEC] do |t|
  sh "gem build #{GEMSPEC}"
end  

