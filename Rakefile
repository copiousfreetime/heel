require 'rubygems'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/rdoctask'
require 'spec/rake/spectask'

$: << File.join(File.dirname(__FILE__),"lib")

require 'heel'

task :default => :spec

#-----------------------------------------------------------------------
# Documentation
#-----------------------------------------------------------------------
namespace :doc do

    # generating documentation locally
    Rake::RDocTask.new do |rdoc|
        rdoc.rdoc_dir   = Heel::SPEC.local_rdoc_dir
        rdoc.options    = Heel::SPEC.rdoc_options 
        rdoc.rdoc_files = Heel::SPEC.rdoc_files
    end

    desc "View the RDoc documentation locally"
    task :view => :rdoc do
        show_files Heel::SPEC.local_rdoc_dir
    end

    # TODO: factor this out into rubyforge namespace
    desc "Deploy the RDoc documentation to rubyforge"
    task :rdoc => :rerdoc do
        sh  "rsync -zav --delete doc/ #{Heel::SPEC.rubyforge_rdoc_dest}"
    end

end

#-----------------------------------------------------------------------
# Testing - TODO factor this out into a separate taslklib
#-----------------------------------------------------------------------
namespace :test do

    Spec::Rake::SpecTask.new do |r|
        r.rcov      = true
        r.rcov_dir  = Heel::SPEC.local_coverage_dir
        r.libs      = Heel::SPEC.require_paths
        r.spec_opts = %w(--format specdoc)
    end

    task :coverage => [:spec] do
        show_files Heel::SPEC.local_coverage_dir
    end

end

#-----------------------------------------------------------------------
# Packaging 
#-----------------------------------------------------------------------
namespace :dist do

    Rake::GemPackageTask.new(Heel::SPEC) do |pkg|
        pkg.need_tar = Heel::SPEC.need_tar
        pkg.need_zip = Heel::SPEC.need_zip
    end

    desc "Install as a gem"
    task :install => [:clobber, :package] do
        sh "sudo gem install pkg/#{Heel::SPEC.full_name}.gem"
    end

    # uninstall the gem and all executables
    desc "Uninstall gem"
    task :uninstall do 
        sh "sudo gem uninstall #{Heel::SPEC.name} -x"
    end

    desc "dump gemspec"
    task :gemspec do
        puts Heel::SPEC.to_ruby
    end

    desc "reinstall gem"
    task :reinstall => [:install, :uninstall]

    # TODO: factor this out into separate tasklib
    desc "Release files to rubyforge"
    task :release => [:clean, :package] do
        rubyforge = RubyForge.new
        rubyforge.login
    end

end

#-----------------------------------------------------------------------
# Distribution
#-----------------------------------------------------------------------
namespace :dist do

end


#-----------------------------------------------------------------------
# TODO: factor website out into its own tasklib
# Website maintenance
#-----------------------------------------------------------------------
namespace :site do

    desc "Build the public website"
    task :build do
    end

    desc "Update the website on rubyforge"
    task :deploy => :build do
        sh "rsync -zav --delete #{Heel::SPEC.local_site_dir} #{Heel::SPEC.remote_site_location}"
    end

    desc "View the website locally"
    task :view => :build do
    end

end
