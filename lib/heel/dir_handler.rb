require 'heel'
require 'mime/types'
require 'erb'
require 'coderay'
require 'coderay/helpers/file_type'

module Heel

  # A refactored version of Mongrel::DirHandler using the mime-types
  # gem and a prettier directory listing.
  class DirHandler < ::Mongrel::HttpHandler
    attr_reader   :document_root
    attr_reader   :directory_index_html
    attr_reader   :icon_url
    attr_reader   :default_mime_type
    attr_reader   :highlighting
    attr_reader   :ignore_globs
    attr_reader   :reload_template_changes
    attr_reader   :template
    attr_reader   :template_mtime
    attr_accessor :listener
    attr_reader   :request_notify


    def initialize(options = {})
      @ignore_globs               = options[:ignore_globs] || %w( *~ .htaccess . )
      @document_root              = options[:document_root] || Dir.pwd
      @directory_listing_allowed  = options[:directory_listing_allowed] || true
      @directory_index_html       = options[:directory_index_html] || "index.html"
      @using_icons                = options[:using_icons] || true
      @icon_url                   = options[:icon_url] || "/heel_icons"
      @reload_template_changes    = options[:reload_template_changes] || false
      @highlighting               = options[:highlighting] || false
      reload_template

    end

    def directory_listing_allowed?
      return !!@directory_listing_allowed
    end

    def using_icons?
      return !!@using_icons
    end

    def reload_template_changes?
      return @reload_template_changes
    end

 end
end
