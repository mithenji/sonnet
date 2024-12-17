defmodule ScorpiusSonnetWeb.Demos.DemoIndexController do
  use ScorpiusSonnetWeb, :controller

  def index(conn, _params) do
    demos = list_available_demos()
    render(conn, :index, demos: demos)
  end

  # 辅助函数
  defp list_available_demos do
    Path.wildcard("priv/static/demos/*/")
    |> Enum.map(&Path.basename/1)
    |> Enum.sort()
  end
end
