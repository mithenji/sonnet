defmodule ScorpiusSonnetWeb.Demos.ReactDemo.PageHTML do
  use ScorpiusSonnetWeb, :html

  def index(assigns) do
    ~H"""
    <div id="demo-react"></div>
    """
  end
end
