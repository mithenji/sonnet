defmodule ScorpiusSonnetWeb.Demos.SolidDemo.PageHTML do
  use ScorpiusSonnetWeb, :html

  def index(assigns) do
    ~H"""
    <div id="demo-solid"></div>
    """
  end
end
