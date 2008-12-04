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
  
  proj_conf = Configuration.for('project')

  namespace :dist do
    desc "Release files to rubyforge"
    task :rubyforge => [:clean, :package] do

      rubyforge = ::RubyForge.new

      config = {}
      config["release_notes"]   = proj_conf.description
      config["release_changes"] = Utils.release_notes_from( proj_conf.history )[Heel::VERSION]
      config["Preformatted"]    = true

      rubyforge.configure config

      # make sure this release doesn't already exist
      releases = rubyforge.autoconfig['release_ids']
      if releases.has_key?(proj_conf.name) and releases[proj_conf.name][Heel::VERSION] then
        abort("Release #{Heel::VERSION} already exists! Unable to release.")
      end


      puts "Uploading to rubyforge..."
      files = FileList[File.join("pkg","#{proj_conf.name}-#{Heel::VERSION}*.*")].to_a
      files.each do |f|
        puts "  * #{f}"
      end

      rubyforge.login
      rubyforge.add_release(rf_conf.project, proj_conf.name, Heel::VERSION, *files)

      puts "done."
    end
  end

  namespace :announce do
    desc "Post news of #{proj_conf.name} to #{rf_conf.project} on rubyforge"
    task :rubyforge do
      info = Utils.announcement

      puts "Subject : #{info['subject']}"
      msg = "#{info[:title]}\n\n#{info[:urls]}\n\n#{info[:release_notes]}"
      puts msg


      rubyforge = RubyForge.new
      rubyforge.configure
      rubyforge.login
      rubyforge.post_news( rf_conf.project, info[:subject], msg )
      puts "Posted to rubyforge"
    end

  end
end
