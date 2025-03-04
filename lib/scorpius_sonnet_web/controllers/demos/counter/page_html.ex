defmodule ScorpiusSonnetWeb.Demos.Counter.PageHTML do
  use ScorpiusSonnetWeb, :html

  def index(assigns) do
    ~H"""
    <div id="demo-counter"></div>
    <%= raw(VitePhx.vite_client("demos")) %>
    <link rel="stylesheet" href={VitePhx.css_path("demos/counter")} />
    <script type="module" src={VitePhx.asset_path("demos/counter")}>
    </script>
    """
  end
end
