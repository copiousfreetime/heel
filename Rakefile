# vim: syntax=ruby
load 'tasks/this.rb'

This.name     = "heel"
This.author   = "Jeremy Hinegardner"
This.email    = "jeremy@copiousfreetime.org"
This.homepage = "http://github.com/copiousfreetime/#{ This.name }"

This.ruby_gemspec do |spec|
  spec.add_runtime_dependency( 'puma'      , '~> 2.0' )
  spec.add_runtime_dependency( 'mime-types', '~> 1.23')
  spec.add_runtime_dependency( 'launchy'   , '~> 2.3' )
  spec.add_runtime_dependency( 'coderay'   , '~> 1.0' )

  spec.add_development_dependency( 'rake'     , '~> 10.1')
  spec.add_development_dependency( 'minitest' , '~> 5.0' )
  spec.add_development_dependency( 'rdoc'     , '~> 4.0' )

  spec.license = "BSD"
end

load 'tasks/default.rake'
