#                                                                  -*- ruby -*-

PACKAGE = 'grizzled-ruby'
GEMSPEC = "#{PACKAGE}.gemspec"
DOC_OUTPUT_DIR = '../gh-pages/rdoc'
RUBY_FILES = FileList['**/*.rb']

def gem_name(spec)
  gem = eval File.open(spec).readlines.join('')
  "#{PACKAGE}-#{gem.version.to_s}.gem"
end

GEM = gem_name(GEMSPEC)

task :default => :build

task :build => [:gem, :doc]

task :gem => GEM

task :doc => RUBY_FILES do |t|
  require 'rdoc/rdoc'
  puts('Running rdoc...')
  r = RDoc::RDoc.new
  r.document(['lib'])
end

task :install => :gem do |t|
  sh "gem install #{GEM}"
end

file GEM => RUBY_FILES + ['Rakefile', GEMSPEC] do |t|
  sh "gem build #{GEMSPEC}"
end  

