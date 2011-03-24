#                                                                  -*- ruby -*-
#
# NOTE: Man pages use the 'ronn' gem. http://rtomayko.github.com/ronn/

require 'rake/clean'
require 'pathname'

PACKAGE = 'grizzled-ruby'
GEMSPEC = "#{PACKAGE}.gemspec"
DOC_OUT_DIR = 'docs'
RDOC_OUT_DIR = File.join(DOC_OUT_DIR, 'rdoc')
MAN_OUT_DIR = File.join(DOC_OUT_DIR, 'man')
GH_PAGES_DIR = File.join('..', 'gh-pages')
RDOC_PUBLISH_DIR = File.join(GH_PAGES_DIR, 'apidocs')
MAN_PUBLISH_DIR = File.join(GH_PAGES_DIR, 'man')
RUBY_FILES = FileList['lib/**/*.rb']
MAN_PAGES = FileList['man/*.md']

def load_gem(spec)
  eval File.open(spec).readlines.join('')
end

def gem_name(spec)
  gem = load_gem(spec)
  "#{PACKAGE}-#{gem.version.to_s}.gem"
end

GEM = gem_name(GEMSPEC)
CLEAN << [GEM, DOC_OUT_DIR]

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
task :doc => [:rdoc, :man]

task :man => MAN_PAGES do |t|
  puts('Running ronn on manual pages...')
  mkdir_p MAN_OUT_DIR
  MAN_PAGES.each do |m|
    base = File.join(MAN_OUT_DIR, File.basename(m, '.md'))
    sh "ronn --html --pipe #{m} >#{base + '.1.html'}"
    sh "ronn --roff --pipe #{m} >#{base + '.1'}"
  end
end  

file 'rdoc' => RUBY_FILES do |t|
  require 'rdoc/rdoc'
  puts('Running rdoc...')
  r = RDoc::RDoc.new
  mkdir_p RDOC_OUT_DIR
  r.document(['-U', '-m', 'lib/grizzled.rb', '-o', RDOC_OUT_DIR, 'lib'])
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
task :pubdoc => [:pubrdoc, :pubman, :pubchangelog]

task :pubrdoc => :doc do |t|
  target = Pathname.new(RDOC_PUBLISH_DIR).expand_path.to_s
  cd RDOC_OUT_DIR do
    mkdir_p target
    cp_r '.', target
  end
end

desc "Publish the man pages. Not really of use to anyone but the author"
task :pubman => :man do |t|
  target = Pathname.new(MAN_PUBLISH_DIR).expand_path.to_s
  cd MAN_OUT_DIR do
    mkdir_p target
    Dir['*.html'].each do |m|
      cp m, target
    end
  end
end

desc "Synonym for 'pubchangelog'"
task :changelog

desc "Publish the change log. Not really of use to anyone but the author"
task :pubchangelog do |t|
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

task :pub

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
