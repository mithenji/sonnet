defmodule ScorpiusSonnetWeb.Demos.ChristmasMeta.PageHTML do
  use ScorpiusSonnetWeb, :html

  def index(assigns) do
    ~H"""
    <div id="container-christmas-meta">
    </div>
    """
  end

  def render("app.html", assigns) do
    ~H"""
    <.flash_group flash={@flash} />
    <%= @inner_content %>
    """
  end
end
