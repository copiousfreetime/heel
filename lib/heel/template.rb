# frozen_string_literal: true

require "erb"

module Heel
  # Internal: A wrapper for an erb template
  #
  class Template
    attr_reader :path, :template, :loaded_at

    def initialize(path)
      @path = path
      @loaded_at = nil
      @template = load_template
    end

    def should_reload?
      loaded_at < last_modified
    end

    def load_template
      @loaded_at = Time.now
     ::ERB.new(File.read(path))
    end

    def last_modified
      File.stat(path).mtime
    end

    def render(binding)
      load_template if should_reload?
      template.result(binding)
    end
  end
end

