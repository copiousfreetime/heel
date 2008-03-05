#--
# Copyright (c) 2007, 2008 Jeremy Hinegardner
# All rights reserved.  Licensed under the BSD license.  See LICENSE for details
#++

require 'tasks/config'

#-----------------------------------------------------------------------
# Rubyforge additions to the task library
#-----------------------------------------------------------------------
if rf_conf = Configuration.for_if_exist?('rubyforge') then
  require 'rubyforge'
  
  prof_conf = Configuration.for('project')

  namespace :dist do
    desc "Release files to rubyforge"
    task :rubyforge => [:clean, :package] do

      rubyforge = ::RubyForge.new

      # make sure this release doesn't already exist
      releases = rubyforge.autoconfig['release_ids']
      if releases.has_key?(prof_conf.name) and releases[prof_conf.name][Heel::VERSION] then
        abort("Release #{Heel::VERSION} already exists! Unable to release.")
      end

      config = rubyforge.userconfig
      config["release_notes"]     = prof_conf.description
      config["release_changes"]   = Utils.release_notes_from(proj_conf.history)[Heel::VERSION]
      config["Prefomatted"]       = true

      puts "Uploading to rubyforge..."
      files = FileList[File.join("pkg","#{prof_conf.name}-#{Heel::VERSION}*.*")].to_a
      rubyforge.login
      rubyforge.add_release(rf_conf.project, prof_conf.name, Heel::VERSION, *files)
      puts "done."
    end
  end

  namespace :announce do
    desc "Post news of #{prof_conf.name} to #{rf_conf.project} on rubyforge"
    task :rubyforge do
      subject, title, body, urls = announcement
      rubyforge = RubyForge.new
      rubyforge.login
      rubyforge.post_news(rf_conf.project, subject, "#{title}\n\n#{urls}\n\n#{body}")
      puts "Posted to rubyforge"
    end

  end
end
