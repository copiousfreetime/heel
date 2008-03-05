#--
# Copyright (c) 2007, 2008 Jeremy Hinegardner
# All rights reserved.  Licensed under the BSD license.  See LICENSE for details
#++

require 'tasks/config'

#-----------------------------------------------------------------------
# Documentation
#-----------------------------------------------------------------------

if rdoc_config = Configuration.for_if_exist?('rdoc') then

  namespace :doc do

    require 'rake/rdoctask'

    # generating documentation locally
    Rake::RDocTask.new do |rdoc|
      rdoc.rdoc_dir   = rdoc_config.output_dir
      rdoc.options    = rdoc_config.options
      rdoc.rdoc_files = rdoc_config.files
      rdoc.title      = rdoc_config.title
      rdoc.main       = rdoc_config.main
    end

    # desc "Deploy the RDoc documentation to #{Heel::SPEC.remote_rdoc_location}"
    # task :deploy => :rerdoc do
      # sh "rsync -zav --delete #{Heel::SPEC.local_rdoc_dir}/ #{Heel::SPEC.remote_rdoc_location}"
    # end

    # if HAVE_HEEL then
      # desc "View the RDoc documentation locally"
      # task :view => :rdoc do
        # sh "heel --root  #{Heel::SPEC.local_rdoc_dir}"
      # end
    # end
  end
end
