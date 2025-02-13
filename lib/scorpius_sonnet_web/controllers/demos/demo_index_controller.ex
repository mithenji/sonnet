defmodule ScorpiusSonnetWeb.Demos.DemoIndexController do
  use ScorpiusSonnetWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def action(conn, params) do
    conn = put_layout(conn, {ScorpiusSonnetWeb.Layouts, :demos})
    super(conn, params)
  end
end
