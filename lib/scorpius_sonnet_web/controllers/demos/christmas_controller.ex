defmodule ScorpiusSonnetWeb.Demos.ChristmasController do
  use ScorpiusSonnetWeb, :controller

  def show(conn, _params) do
    render(conn, :show)
  end
end
