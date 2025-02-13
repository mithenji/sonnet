defmodule ScorpiusSonnetWeb.Demos.DemoController do
  use ScorpiusSonnetWeb, :controller

  plug :put_layout, {ScorpiusSonnetWeb.Layouts, :demos}
  plug :assign_page_title

  def index(conn, _params) do
    render(conn, :index)
  end

  def about(conn, _params) do
    render(conn, :about)
  end

  defp assign_page_title(conn, _opts) do
    title = case conn.path_info do
      ["demos"] -> "演示项目"
      ["demos", "about"] -> "关于演示项目"
      _ -> "Scorpius Sonnet Demos"
    end
    assign(conn, :page_title, title)
  end
end
