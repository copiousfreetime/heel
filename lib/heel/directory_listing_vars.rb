# frozen_string_literal: true

module Heel
  # Internal: Container for variables being sent to a listing template
  #
  DirectoryListingVars = Struct.new(:base_uri, :directory_entries, :highlighting, :homepage, keyword_init: true) do
    def binding_for_template
      binding
    end

    def highlighting?
      highlighting
    end
  end
end
