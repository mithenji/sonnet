defmodule ScorpiusSonnetWeb.VersionController do
  use ScorpiusSonnetWeb, :controller

  def index(conn, _params) do
    json(conn, %{version: "0.1.0"})
  end

  def list(conn, _params) do
    json(conn, %{items: ["item1", "item2", "item3"]})
  end
end
