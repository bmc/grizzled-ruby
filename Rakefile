#                                                                  -*- ruby -*-

require 'rake/clean'

PACKAGE = 'grizzled-ruby'
GEMSPEC = "#{PACKAGE}.gemspec"
DOC_OUTPUT_DIR = '../gh-pages/apidocs'
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

# ---------------------------------------------------------------------------
# Tasks
# ---------------------------------------------------------------------------

task :default => :build

task :build => [:test, :gem, :doc]

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

task :test do |t|
  FileList[File.join('test', '**', 't[cs]_*.rb')].each do |tf|
    cd File.dirname(tf) do |dir|
      ruby File.basename(tf)
    end
  end
end
