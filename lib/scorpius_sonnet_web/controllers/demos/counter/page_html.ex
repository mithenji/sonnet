defmodule ScorpiusSonnetWeb.Demos.Counter.PageHTML do
  use ScorpiusSonnetWeb, :html

  def index(assigns) do
    ~H"""
    <div id="demo-counter"></div>
    """
  end
end
