defmodule ScorpiusSonnetWeb.Demos.DemoIndexController do
  use ScorpiusSonnetWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
