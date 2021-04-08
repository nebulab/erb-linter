# frozen_string_literal: true

require "cgi"
require "ripper"

module ERB::Linter::Converter
  extend self

  # Credit to the Deface gem
  def erb2html(source)
    source = +source

    # all opening html tags that contain <% %> blocks
    source.scan(/<\w+[^<>]+(?:<%.*?%>[^<>]*)+/m).each do |line|
      # regexs to catch <% %> inside attributes id="<% something %>" - with double, single or no quotes
      erb_attrs_regexs = [
        /([\w-]+)(\s?=\s?)(")([^"]*<%.*?%>[^"]*)/m,
        /([\w-]+)(\s?=\s?)(')([^']*<%.*?%>[^']*)'/m,
        /([\w-]+)(\s?=\s?)()(<%.*?%>)(?:\s|>|\z)/m,
      ]

      # rubocop:disable Linter/ShadowingOuterLocalVariable
      replace_line = erb_attrs_regexs.inject(line.clone) do |replace_line, regex|
        replace_line = line.scan(regex).inject(replace_line) do |replace_line, match|
          replace_line.sub("#{match[0]}#{match[1]}#{match[2]}#{match[3]}#{match[2]}") { "data-erb-#{match[0]}=\"#{CGI.escapeHTML(match[3])}\"" }
        end

        replace_line
      end
      # rubocop:enable Linter/ShadowingOuterLocalVariable

      i = -1

      # catch all <% %> inside tags id <p <%= test %>> , not inside attrs
      replace_line.scan(/(<%.*?%>)/m).each do |match|
        replace_line.sub!(match[0], "data-erb-#{i += 1}=\"#{CGI.escapeHTML(match[0])}\"")
      end

      source.sub!(line, replace_line)
    end

    # replaces all <% %> not inside opening html tags
    replacements = [
      { %r{<%\s*end\s*-?%>} => "</erb>" },
      { %r{(^\s*)<%(\s*(?:else|elsif\b.*)\s*)-?%>} => "\\1</erb>\n\\1<erb silent erb-code-start\\2erb-code-end>" },
      { "<%=" => "<erb loud erb-code-start" },
      { "<%" => "<erb silent erb-code-start" },
      { "-%>" => "erb-code-end>" },
      { "%>" => "erb-code-end>" },
    ]

    replacements.each{ |h| h.each { |replace, with| source.gsub! replace, with } }

    source.scan(/(erb-code-start)((?:(?!erb-code-end)[\s\S])*)(erb-code-end)/).each do |match|
      source.sub!("#{match[0]}#{match[1]}#{match[2]}") do |_m|
        code = match[1]

        # is nil when the parsing is broken, meaning it's an open expression
        if Ripper.sexp(code).nil?
          "erb-code=\"#{CGI.escapeHTML(code.gsub("\n", "&#10;"))}\""
        else
          "erb-code=\"#{CGI.escapeHTML(code.gsub("\n", "&#10;"))}\"></erb"
        end
      end
    end

    source
  end
end
