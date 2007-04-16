# make sure our ./lib directory is added to the ruby search path
$: << File.expand_path(File.join(File.dirname(__FILE__),"lib"))

require 'ostruct'
require 'rubygems'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'mongrel_here'

#-----------------------------------------------------------------------
# most of this is out of hoe, but I needed more flexibility in directory
# structures, publishing options for docs and such
#
# Once the build, and runtime dependency issues are resolved with gems
# and hoe has the ability to change the directory that rdocs are
# published to I'll migrate this to using hoe.
#-----------------------------------------------------------------------
PKG_INFO = OpenStruct.new
PKG_INFO.name               = "mongrel_here"
PKG_INFO.rubyforge_name     = PKG_INFO.name.downcase
PKG_INFO.summary            = MongrelHere::DESCRIPTION
PKG_INFO.description        = MongrelHere::DESCRIPTION
PKG_INFO.url                = MongrelHere::HOMEPAGE
PKG_INFO.email              = MongrelHere::AUTHOR_EMAIL
PKG_INFO.author             = MongrelHere::AUTHOR
PKG_INFO.version            = MongrelHere::VERSION.join(".")

PKG_INFO.rdoc_dir           = "doc/rdoc"
PKG_INFO.rdoc_main          = "README"
PKG_INFO.rdoc_title         = "#{PKG_INFO.name} - #{PKG_INFO.version}"
PKG_INFO.rdoc_options       = [ "--line-numbers" , "--inline-source",
                                "--title", PKG_INFO.rdoc_title,
                                "--main", PKG_INFO.rdoc_main ]
PKG_INFO.extra_rdoc_files   = FileList['README', 'CHANGES', 'COPYING']
PKG_INFO.rdoc_files         = FileList['lib/**/*.rb', 'bin/**'] + 
                              PKG_INFO.extra_rdoc_files
PKG_INFO.file_list          = FileList['data/**','vendor/**/*.rb',
                                       'spec/**/*.rb'] + PKG_INFO.rdoc_files
PKG_INFO.publish_dir        = "doc"
PKG_INFO.message            = "\e[1m\e[31m\e[40mTry `keybox --help` for more information\e[0m"

#-----------------------------------------------------------------------
# setup an initial task
#-----------------------------------------------------------------------
desc "Default task"
task :default => :spec

#-----------------------------------------------------------------------
# Packaging and Installation
#-----------------------------------------------------------------------
spec = Gem::Specification.new do |s|
    s.name                  = PKG_INFO.rubyforge_name
    s.rubyforge_project     = PKG_INFO.rubyforge_name
    s.version               = PKG_INFO.version
    s.summary               = PKG_INFO.summary
    s.description           = PKG_INFO.description

    s.author                = PKG_INFO.author
    s.email                 = PKG_INFO.email
    s.homepage              = PKG_INFO.url

    s.files                 = PKG_INFO.file_list
    s.require_paths         << "lib"
    s.executables           = Dir.entries("bin").delete_if { |f| f =~ /^\./ }

    s.extra_rdoc_files      = PKG_INFO.extra_rdoc_files
    s.has_rdoc              = true 
    s.rdoc_options.concat(PKG_INFO.rdoc_options)

    s.post_install_message  = PKG_INFO.message
    s.add_dependency("highline", ">= 1.2.6")
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
    pkg.need_zip = true
end

desc "Install as a gem"
task :install_gem => [:clobber, :package] do
    sh "sudo gem install pkg/*.gem"
end

desc "dump_gemspec"
task :dump_gemspec do
    puts spec.to_ruby
end

#-----------------------------------------------------------------------
# Documentation and Testing (rspec)
#-----------------------------------------------------------------------

rd = Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir   = PKG_INFO.rdoc_dir
    rdoc.title      = PKG_INFO.rdoc_title
    rdoc.main       = PKG_INFO.rdoc_main
    rdoc.rdoc_files = PKG_INFO.rdoc_files
    rdoc.options.concat(PKG_INFO.rdoc_options)
end

rspec = Spec::Rake::SpecTask.new do |r|
    r.warning   = true
    r.rcov      = true
    r.rcov_dir  = "doc/coverage"
    r.libs      << "./lib" 
    r.spec_opts = %w(-f s)
end

# the coverage report is considered documentation
desc "Generate all documentation"
task :docs => [:rdoc,:spec] 

#-----------------------------------------------------------------------
# if we are in the project source code control sandbox then there are
# other tasks available.
#-----------------------------------------------------------------------
if File.directory?("_darcs") then
    require 'tasks/rubyforge'
end
