# frozen_string_literal: true

require "erb"

module ERB::Linter
  VERSION = "0.0.1"

  class Error < StandardError; end

  autoload :Task, "erb/linter/task"
  autoload :Converter, "erb/linter/converter"
  autoload :Checker, "erb/linter/checker"
end
