defmodule ScorpiusSonnetWeb.Demos.IndexHTML.IndexController do
  use ScorpiusSonnetWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def about(conn, _params) do
    render(conn, :about)
  end
end
