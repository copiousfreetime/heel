require 'configuration'

require 'rake'
require 'heel'
require 'heel/configuration'
require 'heel/version'

require 'tasks/utils'

#-----------------------------------------------------------------------
# General project configuration
#-----------------------------------------------------------------------
Configuration.for('project') {
  name          Heel.to_s.downcase
  version       Heel::VERSION
  author        "Jeremy Hinegardner"
  email         "jeremy at hinegardner dot org"
  homepage      Heel::Configuration::HOMEPAGE
  description   Utils.section_of("README", "description")
  summary       description.split(".").first
  history       "HISTORY"
  license       "LICENSE"
  readme        "README"
}

#-----------------------------------------------------------------------
# Packaging 
#-----------------------------------------------------------------------
Configuration.for('packaging') {
  # files in the project 
  proj_conf = Configuration.for('project')
  files {
    bin       FileList["bin/*"]
    lib       FileList["lib/**/*.rb"]
    test      FileList["spec/**/*.rb"]
    data      FileList["data/**/*"]
    tasks     FileList["tasks/**/*.r{ake,b}"]
    rdoc      FileList[proj_conf.readme, proj_conf.history,
                       proj_conf.license] + lib
    all       bin + lib + test + data + rdoc + tasks 
  }

  # ways to package the results
  formats {
    tgz true
    zip true
    rubygem Configuration::Table.has_key?('rubygem')
  }
}

#-----------------------------------------------------------------------
# Gem packaging
#-----------------------------------------------------------------------
Configuration.for("rubygem") {
  spec "gemspec.rb"
  Configuration.for('packaging').files.all << spec
}

#-----------------------------------------------------------------------
# Testing
#-----------------------------------------------------------------------
Configuration.for('test') {
  mode      "spec"
  files     Configuration.for("packaging").files.test
  options   %w[ --format specdoc --color ]
  ruby_opts %w[ ]
}

#-----------------------------------------------------------------------
# Rcov 
#-----------------------------------------------------------------------
Configuration.for('rcov') {
  output_dir  "coverage"
  libs        %w[ lib ]
  rcov_opts   %w[ --html ]
  ruby_opts   %w[ ]
  test_files  Configuration.for('packaging').files.test

  # hmm... how to configure remote publishing
}

#-----------------------------------------------------------------------
# Rdoc 
#-----------------------------------------------------------------------
Configuration.for('rdoc') {
  files       Configuration.for('packaging').files.rdoc
  main        files.first
  title       Configuration.for('project').name
  options     %w[ --line-numbers --inline-source ]
  output_dir  "doc"
}

#-----------------------------------------------------------------------
# Rubyforge 
#-----------------------------------------------------------------------
Configuration.for('rubyforge') {
  project       "copiousfreetime"
  user          "jjh"
  host          "rubyforge.org"
  rdoc_location "#{user}@#{host}:/var/www/gforge-projects/copiousfreetime/heel"
}


