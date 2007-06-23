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
                spec.homepage           = "http://#{spec.rubyforge_project}.rubyforge.org/#{spec.name}/"

                spec.summary            = "A mongrel based webserver."
                spec.description        = <<-DESC
                Heel is a mongrel based webserver to quickly and easily
                serve up the contents of a directory as a webpages.
                DESC

                spec.extra_rdoc_files   = %w[LICENSE README CHANGES]
                spec.has_rdoc           = true
                spec.rdoc_main          = "README"
                spec.rdoc_options       = [ "--line-numbers" , "--inline-source" ]

                spec.test_files         = FileList["spec/**/*.rb"]
                spec.executable         = spec.name
                spec.files              = spec.test_files + spec.extra_rdoc_files + 
                                          FileList["lib/**/*.rb", "resources/**/*"]

                spec.add_dependency("mongrel", ">= 1.0.1")

                spec.platform           = Gem::Platform::RUBY

                spec.local_rdoc_dir     = "doc/rdoc"
                spec.remote_rdoc_dir    = "#{spec.name}/rdoc"
                spec.local_coverage_dir = "doc/coverage"
                spec.remote_coverage_dir= "#{spec.name}/coverage"

                spec.remote_site_dir    = "#{spec.name}/"
           end
end


