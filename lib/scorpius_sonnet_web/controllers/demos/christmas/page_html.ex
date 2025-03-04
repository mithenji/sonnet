defmodule ScorpiusSonnetWeb.Demos.Christmas.PageHTML do
  use ScorpiusSonnetWeb, :html

  def index(assigns) do
    ~H"""
    <div id="demo-christmas"></div>
    <%= raw(VitePhx.vite_client("demos")) %>
    <link rel="stylesheet" href={VitePhx.css_path("demos/christmas")} />
    <script type="module" src={VitePhx.asset_path("demos/christmas")}>
    </script>
    """
  end
end
