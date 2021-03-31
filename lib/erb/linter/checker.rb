# frozen_string_literal: true

require "fileutils"
require "tempfile"

module ERB::Linter::Checker
  extend self

  def check_files(glob = "**/*.erb", tmpdir: Dir.tmpdir, root: Dir.pwd)
    Dir.chdir root do
      print "Checking linthtml version... "
      unless system("yarn -s linthtml -v")
        raise ERB::Linter::Error, "please install linthtml in yarn with `yarn add --dev @linthtml/linthtml`"
      end

      root = File.expand_path(root)
      tmpdir = File.expand_path(File.join(tmpdir, "erb-linter"))
      FileUtils.rm_rf tmpdir

      paths_to_check = []

      paths = Dir[glob]

      paths.sort.map do |path|
        puts "Checking #{path}..."
        Thread.new(path) do |erb_path|
          html_path = File.expand_path("#{tmpdir}/#{erb_path}")
          paths_to_check << html_path
          FileUtils.mkdir_p File.dirname(html_path)
          File.write html_path, ERB::Linter::Converter.erb2html(File.read(erb_path))
        end
      end.each(&:join)

      system "yarn", "-s", "linthtml", *paths_to_check
    end
  end
end
