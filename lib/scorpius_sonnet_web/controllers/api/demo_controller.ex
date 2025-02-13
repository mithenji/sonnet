defmodule ScorpiusSonnetWeb.API.DemoController do
  use ScorpiusSonnetWeb, :controller

  def index(conn, _params) do
    json(conn, %{demos: []})
  end

  def show(conn, %{"id" => id}) do
    json(conn, %{demo: %{id: id}})
  end
end
