#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require 'erb'

module Heel
  # Internal: Generate a directory index
  #
  class DirectoryIndexer
    attr_reader :options
    attr_reader :template_file
    attr_reader :template

    def initialize(template_file, options)
      @template         = nil
      @template_file    = template_file
      @options          = options
      reload_template
    end

    def should_ignore?(fname)
      options[:ignore_globs].each do |glob|
        return true if ::File.fnmatch(glob, fname)
      end
      false
    end

    def mime_map
      @mime_map ||= Heel::MimeMap.new
    end

    def highlighting?
      @options.fetch(:highlighting, false)
    end

    def reload_on_template_change?
      @options.fetch(:reload_template_on_change, false)
    end

    def using_icons?
      @options.fetch(:using_icons, false)
    end

    def reload_template
      fstat = File.stat(@template_file)
      @template_mtime ||= fstat.mtime
      if @template.nil? or fstat.mtime > @template_mtime then
        @template = ::ERB.new(File.read(@template_file))
      end
    end

    # generate the directory index html page of a directory
    #
    def index_page_for(req)
      reload_template if reload_on_template_change?
      dir     = req.request_path
      entries = []
      Dir.entries(dir).each do |entry|
        next if should_ignore?(entry)
        next if dir == @options[:document_root] and entry == ".."

        stat            = File.stat(File.join(dir, entry))
        entry_data      = OpenStruct.new

        entry_data.name          = entry == ".." ? "Parent Directory" : entry
        entry_data.link          = ERB::Util.url_encode(entry)
        entry_data.size          = num_to_bytes(stat.size)
        entry_data.last_modified = stat.mtime.strftime("%Y-%m-%d %H:%M:%S")

        if stat.directory? then
          entry_data.content_type = "Directory"
          entry_data.size         = "-"
          entry_data.name        += "/"
          if using_icons? then
            entry_data.icon_url = File.join(options[:icon_url], MimeMap.icons_by_mime_type[:directory])
          end
        else
          entry_data.mime_type = mime_map.mime_type_of(entry)
          entry_data.content_type = entry_data.mime_type.content_type
          if using_icons? then
            entry_data.icon_url = File.join(options[:icon_url], mime_map.icon_for(entry_data.mime_type))
          end
        end
        entries << entry_data
      end

      template_vars          = TemplateVars.new(base_uri: req.path_info, highlighting: highlighting?)
      template_vars.entries  = entries.sort_by { |e| e.link }
      template_vars.homepage = Heel::Configuration::HOMEPAGE

      return template.result(template_vars.binding_for_template)
    end

    # essentially this is strfbytes from facets
    #
    def num_to_bytes(num, fmt = "%.2f")
      case
      when num < 1024
        "#{num} bytes"
      when num < 1024**2
        "#{fmt % (num.to_f / 1024)} KB"
      when num < 1024**3
        "#{fmt % (num.to_f / (1024**2))} MB"
      when num < 1024**4
        "#{fmt % (num.to_f / (1024**3))} GB"
      when num < 1024**5
        "#{fmt % (num.to_f / (1024**4))} TB"
      else
        "#{num} bytes"
      end
    end
  end
end
