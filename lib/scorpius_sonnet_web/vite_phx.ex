defmodule VitePhx do
  @moduledoc """
  提供 Vite 资源路径处理的辅助函数
  """

  def asset_path(entry) do
    if Mix.env() == :dev do
      "http://0.0.0.0:5175/#{entry}"
    else
      # 在生产环境中，资源文件会被编译到 priv/static 目录
      "/#{entry}"
    end
  end

  def vite_client do
    if Mix.env() == :dev do
      ~s(<script type="module" src="http://0.0.0.0:5175/@vite/client"></script>)
    end
  end
end
