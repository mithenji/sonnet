defmodule ScorpiusSonnetWeb.Demos.VueDemo.PageHTML do
  use ScorpiusSonnetWeb, :html

  def index(assigns) do
    ~H"""
    <div id="demo-vue"></div>
    """
  end
end
