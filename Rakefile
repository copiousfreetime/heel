# vim: syntax=ruby
load 'tasks/this.rb'

This.name     = "heel"
This.author   = "Jeremy Hinegardner"
This.email    = "jeremy@copiousfreetime.org"
This.homepage = "http://github.com/copiousfreetime/#{ This.name }"

This.ruby_gemspec do |spec|
  spec.add_runtime_dependency( 'rack'      , '~> 3.0' )
  spec.add_runtime_dependency( 'puma'      , '~> 6.0' )
  spec.add_runtime_dependency( 'mime-types', '~> 3.4')
  spec.add_runtime_dependency( 'launchy'   , '~> 2.5' )
  spec.add_runtime_dependency( 'coderay'   , '~> 1.1' )

  spec.add_development_dependency( 'rake'     , '~> 13.0')
  spec.add_development_dependency( 'minitest' , '~> 5.15' )
  spec.add_development_dependency( 'minitest-junit' , '~> 1.0' )
  spec.add_development_dependency( 'rdoc'     , '~> 6.5' )
  spec.add_development_dependency( 'simplecov', '~> 0.21' )

  spec.license = "BSD-3-Clause"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/copiousfreetime/heel/issues",
    "changelog_uri"   => "https://github.com/copiousfreetime/heel/blob/master/README.md",
    "homepage_uri"    => "https://github.com/copiousfreetime/heel",
    "source_code_uri" => "https://github.com/copiousfreetime/heel",
  }

end

load 'tasks/default.rake'
