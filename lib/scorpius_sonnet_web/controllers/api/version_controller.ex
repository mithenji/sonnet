defmodule ScorpiusSonnetWeb.API.VersionController do
  use ScorpiusSonnetWeb, :controller

  def show(conn, _params) do
    json(conn, %{version: "1.0.0"})
  end
end
