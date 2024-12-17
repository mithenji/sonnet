defmodule ScorpiusSonnetWeb.DemoController do
  use ScorpiusSonnetWeb, :controller

  def show(conn, %{"demo_id" => demo_name}) do
    version = "1.0.0"
    render(conn, :show, demo: demo_name, version: version)
  end
end
