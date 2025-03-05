defmodule ScorpiusSonnetWeb.Demos.SolidDemo.PageController do
  use ScorpiusSonnetWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
