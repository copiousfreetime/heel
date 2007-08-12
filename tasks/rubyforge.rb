require 'rubyforge'

#-----------------------------------------------------------------------
# Documentation - pushing documentation to rubyforge
#-----------------------------------------------------------------------
namespace :doc do
    desc "Deploy the RDoc documentation to rubyforge"
    task :deploy => :rerdoc do
        sh "rsync -zav --delete #{Heel::SPEC.local_rdoc_dir}/ #{Heel::SPEC.remote_rdoc_location}"
    end
end

#-----------------------------------------------------------------------
# Packaging and Distribution - push to rubyforge
#-----------------------------------------------------------------------
namespace :dist do
    desc "Release files to rubyforge"
    task :release => [:clean, :package] do
        
        rubyforge = RubyForge.new
        
        # make sure this release doesn't already exist
        releases = rubyforge.autoconfig['release_ids']
        if releases.has_key?(Heel::SPEC.name) and releases[Heel::SPEC.name][Heel::VERSION] then
            abort("ERROR: Release #{Heel::VERSION} already exists!  Unable to release.")
        end
        
        config = rubyforge.userconfig
        config["release_notes"]     = Heel::SPEC.description
        config["release_changes"]   = last_changeset
        config["Prefomatted"]       = true


        puts "Uploading to rubyforge..."
        files = FileList[File.join("pkg","#{Heel::SPEC.name}-#{Heel::VERSION}.*")].to_a
        rubyforge.login
        rubyforge.add_release(Heel::SPEC.rubyforge_project, Heel::SPEC.name, Heel::VERSION, *files)
        puts "done."
    end
end

#-----------------------------------------------------------------------
# Announcements - Create an email text file, and post news to rubyforge
#-----------------------------------------------------------------------
def changes
    change_file = File.expand_path(File.join(File.basename(__FILE__),"..","CHANGES"))
    sections    = File.read(change_file).split(/^(?===)/)
end
def last_changeset
    changes[1]
end

def announcement
    urls    = "  #{Heel::SPEC.homepage}"
    subject = "#{Heel::SPEC.name} #{Heel::VERSION} Released"
    title   = "#{Heel::SPEC.name} version #{Heel::VERSION} has been released."
    body    = <<BODY
#{Heel::SPEC.description.rstrip}

{{ Changelog for Version #{Heel::VERSION} }}

#{last_changeset.rstrip}

BODY

    return subject, title, body, urls
end

namespace :announce do
    desc "create email for ruby-talk"
    task :email do
        subject, title, body, urls = announcement

        File.open("email.txt", "w") do |mail|
            mail.puts "From: #{Heel::SPEC.author} <#{Heel::SPEC.email}>"
            mail.puts "To: ruby-talk@ruby-lang.org"
            mail.puts "Date: #{Time.now.rfc2822}"
            mail.puts "Subject: [ANN] #{subject}"
            mail.puts
            mail.puts title
            mail.puts
            mail.puts urls
            mail.puts 
            mail.puts body
            mail.puts 
            mail.puts urls
        end
        puts "Created the following as email.txt:"
        puts "-" * 72
        puts File.read("email.txt")
        puts "-" * 72
    end
    
    CLOBBER << "email.txt"

    desc "Post news of #{Heel::SPEC.name} to #{Heel::SPEC.rubyforge_project} on rubyforge"
    task :post_news do
        subject, title, body, urls = announcement
        rubyforge = RubyForge.new
        rubyforge.login
        rubyforge.post_news(Heel::SPEC.rubyforge_project, subject, "#{title}\n\n#{urls}\n\n#{body}")
        puts "Posted to rubyforge"
    end

end
