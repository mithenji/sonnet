defmodule ScorpiusSonnetWeb.Demos.ChristmasMeta.PageHTML do
  use ScorpiusSonnetWeb, :html

  embed_templates "page_html/*"

  def render("app.html", assigns) do
    ~H"""
    <.flash_group flash={@flash} />
    <%= @inner_content %>
    """
  end
end
