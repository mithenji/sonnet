defmodule ScorpiusSonnetWeb.Demos.DemoIndexHTML do
  use ScorpiusSonnetWeb, :html

  embed_templates "demo_index_html/*"

  # 获取资产哈希值的辅助函数
  def get_asset_hash do
    # 在开发环境中可以返回固定值
    if Mix.env() == :dev do
      "dev"
    else
      # 在生产环境中，您需要实现资产哈希的获取逻辑
      "production-hash"
    end
  end
end
