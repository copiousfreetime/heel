# frozen_string_literal: true

require "spec_helper"

describe Heel::MimeMap do
  [
    { ext: "svg", type: "image/svg+xml" },
    { ext: "flv", type: "video/x-flv" },
    { ext: "rb", type: "text/x-ruby" },
    { ext: "rhtml", type: "application/octet-stream" },
  ].each do |m|
    it "finds #{m[:ext]} extension in the map as #{m[:type]}" do
      _(Heel::MimeMap.mime_type_of("test.#{m[:ext]}")).must_equal m[:type]
    end
  end

  %w[md markdown rdoc].each do |ext|
    it "finds #{ext} in the map as text/markdown" do
      _(Heel::MimeMap.mime_type_of("test.#{ext}")).must_equal "text/markdown"
    end
  end

  it "finds the default if the extension is not in the map" do
    _(Heel::MimeMap.mime_type_of("test.foo")).must_equal "application/octet-stream"
  end

  it "finds the default icon if the mime type does not exist" do
    _(Heel::MimeMap.icon_for("test.foo")).must_equal "file.svg"
  end
end
