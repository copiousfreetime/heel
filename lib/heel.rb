#--
# Copyright (c) 2007, 2008 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license.  See LICENSE for details
#++

module Heel
  # recursively descend the directory with the same name as this file and do a
  # require 'heel/path/to/file'
  #
  def self.require_all_libs_relative_to_me
    remove_parent = File.dirname(File.expand_path(__FILE__)) + File::SEPARATOR
    descend_dir   = File.join(remove_parent,File.basename(__FILE__, ".rb"))

    Dir.glob("#{descend_dir}/**/*.rb").each do |rb|
      lib = rb.gsub(remove_parent,'')
      require lib
    end
  end
end

Heel.require_all_libs_relative_to_me
