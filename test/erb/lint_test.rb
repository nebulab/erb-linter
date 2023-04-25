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
            <span data-action="foo->#bar" <%= :bar if bar %>></span>
            <span data-foo="<%= :foo %>" <%= :bar if bar %>></span>
            <span data-<% identifier %>="bar" data-<% identifier %>-foo="<%= 'bar' %>"></span>
            <span <%= :foo if foo %> <%= :bar if bar %>></span>
            <span data-foo="<%= "foo" %>" <%= "bar" if bar %>></span>
            <input <%= :foo if foo %> <%= :bar if bar %>/>

              <span
            data-foo="<%= "foo" %>"
                   autocomplete

                  <%= "bar" if bar %>
           data-foo="bar><!'"
           ></span>
           <test
             data-controller="foo"
             data-foo-configuration-value='{
               "bar0": true,
               "bar1": true,
               "bar2": false,
               "bar3": false,
               "bar4": <%= @bar %>
             }'
           >
          </div>
        ERB
      ).must_equal(
        <<~HTML
          <div>
            <span data-action="foo->#bar" data-erb-0="&lt;%= :bar if bar %&gt;"></span>
            <span data-erb-data-foo="&lt;%= :foo %&gt;" data-erb-0="&lt;%= :bar if bar %&gt;"></span>
            <span data-erb-data-<erb silent erb-code=\" identifier \"></erb>=\"bar\" data-erb-data-<erb silent erb-code=\" identifier \"></erb>-foo=\"&lt;%= &#39;bar&#39; %&gt;\"></span>
            <span data-erb-0="&lt;%= :foo if foo %&gt;" data-erb-1="&lt;%= :bar if bar %&gt;"></span>
            <span data-erb-data-foo="&lt;%= &quot;foo&quot; %&gt;" data-erb-0="&lt;%= &quot;bar&quot; if bar %&gt;"></span>
            <input data-erb-0="&lt;%= :foo if foo %&gt;" data-erb-1="&lt;%= :bar if bar %&gt;"/>

              <span
            data-erb-data-foo="&lt;%= &quot;foo&quot; %&gt;"
                   autocomplete

                  data-erb-0="&lt;%= &quot;bar&quot; if bar %&gt;"
           data-foo="bar><!'"
           ></span>
           <test
             data-controller="foo"
             data-erb-data-foo-configuration-value='{
               &quot;bar0&quot;: true,
               &quot;bar1&quot;: true,
               &quot;bar2&quot;: false,
               &quot;bar3&quot;: false,
               &quot;bar4&quot;: &lt;%= @bar %&gt;
             }'
           >
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
