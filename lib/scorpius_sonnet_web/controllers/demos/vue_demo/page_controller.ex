defmodule ScorpiusSonnetWeb.Demos.VueDemo.PageController do
  use ScorpiusSonnetWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
