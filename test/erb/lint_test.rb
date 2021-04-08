# frozen_string_literal: true

require "test_helper"

describe ERB::Linter do
  it "has a version number" do
    refute_nil ::ERB::Linter::VERSION
  end

  describe ".erb2html" do
    specify "elsif" do
      converted_html(
        <<~ERB
          <div>
            <% if @foo == :bar %>
              <%= image_tag(item[:value], alt: item[:value]) %>
            <% elsif @type == :other %>
              <span><%= item[:value] %></span>
            <% else %>
              <% raise "unknown type" %>
            <% end %>
          </div>
        ERB
      ).must_equal(
        <<~HTML
          <div>
            <erb silent erb-code=" if @foo == :bar ">
              <erb loud erb-code=" image_tag(item[:value], alt: item[:value]) "></erb>
            </erb>
            <erb silent erb-code=" elsif @type == :other ">
              <span><erb loud erb-code=" item[:value] "></erb></span>
            </erb>
            <erb silent erb-code=" else ">
              <erb silent erb-code=" raise &quot;unknown type&quot; "></erb>
            </erb>
          </div>
        HTML
      )
    end

    specify "attributes" do
      converted_html(
        <<~ERB
          <div>
            <span data-foo="<%= :foo %>" <%= :bar if bar %>></span>
            <span <%= :foo if foo %> <%= :bar if bar %>></span>
            <span data-foo="<%= "foo" %>" <%= "bar" if bar %>></span>
          </div>
        ERB
      ).must_equal(
        <<~HTML
          <div>
            <span data-erb-data-foo="&lt;%= :foo %&gt;" data-erb-0="&lt;%= :bar if bar %&gt;"></span>
            <span data-erb-0="&lt;%= :foo if foo %&gt;" data-erb-1="&lt;%= :bar if bar %&gt;"></span>
            <span data-erb-data-foo="&lt;%= &quot;foo&quot; %&gt;" data-erb-0="&lt;%= &quot;bar&quot; if bar %&gt;"></span>
          </div>
        HTML
      )
    end
  end

  private

  def converted_html(src)
    _(ERB::Linter::Converter.erb2html(src))
  end
end
