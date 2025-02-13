defmodule ScorpiusSonnetWeb.Demos.HomeController do
  use ScorpiusSonnetWeb, :controller

  def index(conn, _params) do
    demos = [
      %{title: "圣诞演示", description: "圣诞主题动画", path: ~p"/demos/christmas"},
      %{title: "计数器", description: "Vue 计数器", path: ~p"/demos/counter"},
      %{title: "React演示", description: "React应用", path: ~p"/demos/react-demo"}
    ]

    render(conn, :index, demos: demos)
  end
end
