defmodule ScorpiusSonnetWeb.Demos.ReactDemo.PageHTML do
  use ScorpiusSonnetWeb, :html

  def index(assigns) do
    ~H"""
    <div id="demo-react"></div>
    <script type="module">
      import RefreshRuntime from "http://localhost:5173/@react-refresh"
      RefreshRuntime.injectIntoGlobalHook(window)
      window.$RefreshReg$ = () => {}
      window.$RefreshSig$ = () => (type) => type
      window.__vite_plugin_react_preamble_installed__ = true
    </script>
    <%= raw(VitePhx.vite_client("demos")) %>

    <%# 使用entry_tags函数，一次性生成所有需要的资源标签 %>
    <%= raw(VitePhx.entry_tags("demos/react-demo")) %>
    """
  end
end
