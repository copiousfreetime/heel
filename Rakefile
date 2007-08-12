require 'rubygems'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/contrib/sshpublisher'
require 'spec/rake/spectask'

$: << File.join(File.dirname(__FILE__),"lib")

require 'heel'

# load all the extra tasks for the project
TASK_DIR = File.join(File.dirname(__FILE__),"tasks")
FileList[File.join(TASK_DIR,"*.rb")].each do |tasklib|
    require "tasks/#{File.basename(tasklib)}"
end

task :default => 'test:default'

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

end


#-----------------------------------------------------------------------
# Packaging and Distribution  
#-----------------------------------------------------------------------
namespace :dist do
    
    GEM_SPEC = eval(Heel::SPEC.to_ruby)

    Rake::GemPackageTask.new(GEM_SPEC) do |pkg|
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

    desc "distribute copiously"
    task :copious => [:package] do
        Rake::SshFilePublisher.new('jeremy@copiousfreetime.org',
                               '/var/www/vhosts/www.copiousfreetime.org/htdocs/gems/gems',
                               'pkg',"#{Heel::SPEC.full_name}.gem").upload
        sh "ssh jeremy@copiousfreetime.org rake -f /var/www/vhosts/www.copiousfreetime.org/htdocs/gems/Rakefile"
    end

end


#-----------------------------------------------------------------------
# update the top level clobber task to depend on all possible sub-level
# tasks that have a name like ':clobber'  in other namespaces
#-----------------------------------------------------------------------
Rake.application.tasks.each do |t|
    if t.name =~ /:clobber/ then
        task :clobber => [t.name]
    end
end
