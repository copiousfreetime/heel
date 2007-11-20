require 'rubygems'
require 'heel/specification'
require 'heel/version'
require 'rake'

module Heel
    SPEC = Heel::Specification.new do |spec|
                spec.name               = "heel"
                spec.version            = Heel::VERSION
                spec.rubyforge_project  = "copiousfreetime"
                spec.author             = "Jeremy Hinegardner"
                spec.email              = "jeremy@hinegardner.org"
                spec.homepage           = "http://copiousfreetime.rubyforge.org/heel/"

                spec.summary            = "A mongrel based static file webserver."
                spec.description        = <<-DESC
                Heel is a mongrel based web server to quickly and easily serve up the
                contents of a directory as webpages.  Beyond just serving up webpages
                heel uses an ERB template and famfamfam icons to create useful index
                pages.
                
                And to make things even easier it launches your browser for you so no
                cut and paste necessary.
                DESC

                spec.extra_rdoc_files   = FileList["CHANGES", "LICENSE", "README"]
                spec.has_rdoc           = true
                spec.rdoc_main          = "README"
                spec.rdoc_options       = [ "--line-numbers" , "--inline-source" ]

                spec.test_files         = FileList["spec/**/*.rb"]
                spec.executable         = spec.name
                spec.files              = spec.test_files + spec.extra_rdoc_files + 
                                          FileList["lib/**/*.rb", "resources/**/*"]

                spec.add_dependency("mongrel", ">= 1.0.1")
                spec.add_dependency("launchy", ">= 0.3.0")
                spec.add_dependency("mime-types", ">= 1.15")
                spec.add_dependency("coderay", ">= 0.7.4.215")
                spec.add_dependency("rake", ">= 0.7.3")
                
                spec.required_ruby_version  = ">= 1.8.5"

                spec.platform = Gem::Platform::RUBY

                spec.remote_user        = "jjh"
                spec.local_rdoc_dir     = "doc/rdoc"
                spec.remote_rdoc_dir    = ""
                spec.local_coverage_dir = "doc/coverage"

                spec.remote_site_dir    = "#{spec.name}/"

           end
end


