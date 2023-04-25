# frozen_string_literal: true

require "cgi"
require "ripper"
require 'securerandom'
require 'strscan'

module ERB::Linter::Converter
  extend self

  # https://stackoverflow.com/a/317081
  ATTR_NAME = %r{[^\r\n\t\f\v= '"<>]*[^\r\n\t\f\v= '"<>/]} # not ending with a slash
  UNQUOTED_VALUE = ATTR_NAME
  UNQUOTED_ATTR = %r{#{ATTR_NAME}=#{UNQUOTED_VALUE}}
  SINGLE_QUOTE_ATTR = %r{(?:#{ATTR_NAME}='[^']*')}
  DOUBLE_QUOTE_ATTR = %r{(?:#{ATTR_NAME}="[^"]*")}

  ERB_TAG = %r{<%.*?%>}
  HTML_ATTR = %r{\s+#{SINGLE_QUOTE_ATTR}|\s+#{DOUBLE_QUOTE_ATTR}|\s+#{UNQUOTED_ATTR}|\s+#{ATTR_NAME}}
  HTML_TAG = %r{(<\w+)((?:#{HTML_ATTR})*)(\s*)(/>|>)}m

  # (credit goes to the Deface gem for the original implementation)
  def erb2html(source)
    source = +source

    # encode all erb tags so that the HTML looks valid
    erb_tags = {}
    source.gsub!(ERB_TAG) do |tag|
      uid = ["ERB_", SecureRandom.uuid].join.delete('-')
      erb_tags[uid] = tag
      uid
    end

    erb_tags_matcher = Regexp.union(erb_tags.keys)

    # transform/escape all the erb-attributes first
    source.gsub!(HTML_TAG).each do |match|
      line = Regexp.last_match.to_a[1..-1]
      tag = [line[0], line[2]+line[3]]

      # scan each attribute into an array
      attr_scanner = StringScanner.new(line[1])
      attributes = []
      attributes << (attr_scanner.scan(HTML_ATTR) or raise "Can't scan: #{attr_scanner.string}") until attr_scanner.eos?
      # attributes.compact!

      i = -1
      attributes.map! do |attribute|
        if attribute.match?(erb_tags_matcher)
          space, attribute = attribute.scan(/\A(\s+)(.*)\z/m).flatten

          attribute =
            case
            when /\A#{ERB_TAG}\z/ === attribute.gsub(erb_tags_matcher, erb_tags)
              %{data-erb-#{i += 1}="#{CGI.escapeHTML(attribute.gsub(erb_tags_matcher, erb_tags))}"}
            when /\A#{ATTR_NAME}=/ === attribute
              name, value = attribute.split("=", 2).map { _1.gsub(erb_tags_matcher, erb_tags) }
              quote = '"'
              if value.match(/\A['"]/)
                quote = value[0]
                value = value[1...-1]
              end
              %{data-erb-#{name}=#{quote}#{CGI.escapeHTML(value)}#{quote}}
            else
              raise "Don't know how to process attribute: #{attribute.gsub(erb_tags_matcher, erb_tags).inspect}"
            end

          "#{space}#{attribute}"
        else
          attribute
        end
      end

      [tag[0], *attributes, tag[1]].join
    end

    # restore the encoded erb tags
    source.gsub!(erb_tags_matcher, erb_tags)

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
