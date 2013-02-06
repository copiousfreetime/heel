# vim: syntax=ruby
load 'tasks/this.rb'

This.name     = "heel"
This.author   = "Jeremy Hinegardner"
This.email    = "jeremy@copiousfreetime.org"
This.homepage = "http://github.com/copiousfreetime/#{ This.name }"

This.ruby_gemspec do |spec|
  spec.add_runtime_dependency( 'puma'      , '~> 1.0' )
  spec.add_runtime_dependency( 'mime-types', '~> 1.19'  )
  spec.add_runtime_dependency( 'launchy'   , '~> 2.2' )
  spec.add_runtime_dependency( 'coderay'   , '~> 1.0.7' )

  spec.add_development_dependency( 'rake'     , '~> 10.0.3')
  spec.add_development_dependency( 'minitest' , '~> 4.5.0' )
  spec.add_development_dependency( 'rdoc'     , '~> 3.12'   )
end

load 'tasks/default.rake'
