#                                                                  -*- ruby -*-

require 'rake/clean'

PACKAGE = 'grizzled-ruby'
GEMSPEC = "#{PACKAGE}.gemspec"
DOC_DIR = 'rdoc'
GH_PAGES_DIR = File.join('..', 'gh-pages')
DOC_PUBLISH_DIR = File.join(GH_PAGES_DIR, 'apidocs')
RUBY_FILES = FileList['lib/**/*.rb']

def load_gem(spec)
  eval File.open(spec).readlines.join('')
end

def gem_name(spec)
  gem = load_gem(spec)
  "#{PACKAGE}-#{gem.version.to_s}.gem"
end

GEM = gem_name(GEMSPEC)
CLEAN << [GEM, DOC_DIR]

# ---------------------------------------------------------------------------
# Tasks
# ---------------------------------------------------------------------------

task :default => :build

desc "Build everything"
task :build => [:test, :gem, :doc]

desc "Synonym for 'build'"
task :all => :build

desc "Build the gem (#{GEM})"
task :gem => GEM

file GEM => RUBY_FILES + ['Rakefile', GEMSPEC] do |t|
  sh "gem build #{GEMSPEC}"
end  

desc "Build the documentation, locally"
task :doc => :rdoc

file 'rdoc' => RUBY_FILES do |t|
  require 'rdoc/rdoc'
  puts('Running rdoc...')
  r = RDoc::RDoc.new
  r.document(['-U', '-m', 'lib/grizzled.rb', '-o', DOC_DIR, 'lib'])
end

desc "Install the gem"
task :install => :gem do |t|
  sh "gem install #{GEM}"
end

desc "Publish the gem"
task :publish => :gem do |t|
  sh "gem push #{GEM}"
end

desc "Publish the docs. Not really of use to anyone but the author"
task :pubdoc => :doc do |t|
  require 'pathname'
  target = Pathname.new(DOC_PUBLISH_DIR).expand_path.to_s
  cd DOC_DIR do
    mkdir_p target
    cp_r '.', target
  end

  File.open(File.join(GH_PAGES_DIR, 'CHANGELOG.md'), 'w') do |f|
    f.write <<EOF
---
title: Change Log for Grizzled Ruby
layout: default
---

EOF
    f.write File.open('CHANGELOG.md').read
    f.close
  end
end

desc "Alias for 'docpub'"
task :docpub => :pubdoc

desc "Run the unit tests"
task :test do |t|
  FileList[File.join('test', '**', 't[cs]_*.rb')].each do |tf|
    cd File.dirname(tf) do |dir|
      ruby File.basename(tf)
    end
  end
end
