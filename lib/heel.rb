# frozen_string_literal: true

require "zeitwerk"
Zeitwerk::Loader.new.then do |loader|
  loader.inflector.inflect("erb" => "ERB")
  loader.tag = File.basename(__FILE__, ".rb")
  loader.push_dir(__dir__)
  loader.setup
end

# Heel namespace and version
module Heel
  VERSION = "4.0.1"

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
