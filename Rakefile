# vim: syntax=ruby
load 'tasks/this.rb'

This.name     = "heel"
This.author   = "Jeremy Hinegardner"
This.email    = "jeremy@copiousfreetime.org"
This.homepage = "http://github.com/copiousfreetime/#{ This.name }"

This.ruby_gemspec do |spec|
  spec.add_runtime_dependency( 'rack'      , '~> 2.0' )
  spec.add_runtime_dependency( 'puma'      , '~> 3.11' )
  spec.add_runtime_dependency( 'mime-types', '~> 3.1')
  spec.add_runtime_dependency( 'launchy'   , '~> 2.4' )
  spec.add_runtime_dependency( 'coderay'   , '~> 1.1' )

  spec.add_development_dependency( 'rake'     , '~> 12.3')
  spec.add_development_dependency( 'minitest' , '~> 5.11' )
  spec.add_development_dependency( 'rdoc'     , '~> 6.0' )
  spec.add_development_dependency( 'simplecov', '~> 0.15' )

  spec.license = "BSD-3-Clause"
end

load 'tasks/default.rake'
