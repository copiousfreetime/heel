#--
# Copyright (c) 2007, 2008 Jeremy Hinegardner
# All rights reserved.  Licensed under the BSD license.  See LICENSE for details
#++

require 'tasks/config'

#-------------------------------------------------------------------------------
# configuration for running rspec.  This shows up as the test:default task
#-------------------------------------------------------------------------------

if spec_config = Configuration.for_if_exist?('test') then

  namespace :test do

    task :default => :spec

    require 'spec/rake/spectask'
    Spec::Rake::SpecTask.new do |r| 
      r.rcov        = spec_config.ruby_opts
      r.libs        = [ Heel::Configuration.lib_path,
        Heel::Configuration.root_dir ]
      r.spec_files  = spec_config.files
      r.spec_opts   = spec_config.options

      if rcov_config = Configuration.for_if_exist?('rcov') then
        r.rcov      = true
        r.rcov_dir  = rcov_config.output_dir
        r.rcov_opts = rcov_config.rcov_opts
      end
    end
  end
end
