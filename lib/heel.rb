# frozen_string_literal: true

require "zeitwerk"
Zeitwerk::Loader.new.then do |loader|
  loader.inflector = Zeitwerk::GemInflector.new(__FILE__)
  loader.tag = File.basename(__FILE__, ".rb")
  loader.push_dir(__dir__)
  loader.setup
end

# Heel namespace and version
module Heel
  def self.loader(registry = Zeitwerk::Registry)
    @loader ||= registry.loaders.find { |loader| loader.tag == File.basename(__FILE__, ".rb") }
  end
end

# Stdlib and Gems
require "erb"
require "fileutils"
require "launchy"
require "marcel"
require "pathname"
require "puma"
require "rack"
require "rack/utils"
require "rackup"
require "rouge"
require "time"
