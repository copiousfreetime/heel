# frozen_string_literal: true

module Heel
  # Internal: A wrapper for an erb template
  #
  class Template
    attr_reader :path, :template, :loaded_at

    def initialize(path)
      @path = path
      @loaded_at = Time.at(0)
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
      @template = load_template if should_reload?
      template.result(binding)
    end
  end
end
