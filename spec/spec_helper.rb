# frozen_string_literal: true

require 'simplecov'
SimpleCov.start if ENV['COVERAGE']

gem 'minitest'
require 'heel'
require 'minitest/autorun'
require 'minitest/pride'
