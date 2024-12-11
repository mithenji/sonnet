defmodule ScorpiusSonnetWeb.Demos.DemoController do
  use ScorpiusSonnetWeb, :controller

  def index(conn, _params) do
    demos = list_available_demos()
    render(conn, :index, demos: demos)
  end

  def show(conn, %{"demo_id" => demo_id}) do
    case demo_exists?(demo_id) do
      true -> render(conn, :show, demo_id: demo_id)
      false -> redirect(conn, to: ~p"/demos")
    end
  end

  # 辅助函数
  defp list_available_demos do
    Path.wildcard("priv/static/demos/*/")
    |> Enum.map(&Path.basename/1)
    |> Enum.sort()
  end

  defp demo_exists?(demo_id) do
    File.exists?("priv/static/demos/#{demo_id}")
  end
end
