defmodule ScorpiusSonnetWeb.PageController do
  use ScorpiusSonnetWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
