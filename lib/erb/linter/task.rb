# frozen_string_literal: true

require "tempfile"

class ERB::Linter::Task < Rake::TaskLib
  attr_accessor :name, :glob, :root, :tmpdir

  def initialize(*args, &block)
    @name = args.shift || :erb_linter
    @glob = "**/*.erb"
    @root = Dir.pwd
    @tmpdir = Dir.tmpdir

    yield self

    desc 'Check ERB files for HTML correcteness'
    task(name, *args) do |_, task_args|
      run
    end
  end

  private

  def run
    success = ERB::Linter::Checker.check_files(glob, root: root, tmpdir: tmpdir)

    exit(success)
  rescue ERB::Linter::Error => error
    abort error.message
  end
end
