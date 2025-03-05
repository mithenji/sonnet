defmodule ScorpiusSonnetWeb.Demos.SvelteDemo.PageHTML do
  use ScorpiusSonnetWeb, :html

  def index(assigns) do
    ~H"""
    <div id="demo-svelte"></div>
    """
  end
end
