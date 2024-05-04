# frozen_string_literal: true

require "spec_helper"

describe Heel::MimeMap do
  [
    { ext: "svg", type: "image/svg+xml" },
    { ext: "flv", type: "video/x-flv" },
    { ext: "rb", type: "text/plain" },
    { ext: "rhtml", type: "text/plain" },
  ].each do |m|
    it "finds #{m[:ext]} extension in the map as #{m[:type]}" do
      _(Heel::MimeMap.mime_type_of("test.#{m[:ext]}")).must_equal m[:type]
    end
  end

  %w[md markdown rdoc].each do |ext|
    it "finds #{ext} in the map as text/plain" do
      _(Heel::MimeMap.mime_type_of("test.#{ext}")).must_equal "text/plain"
    end
  end
end
