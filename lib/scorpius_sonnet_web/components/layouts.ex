defmodule ScorpiusSonnetWeb.Layouts do
  use ScorpiusSonnetWeb, :html

  embed_templates "layouts/*"

  # 只保留辅助函数
  def get_asset_hash do
    if Mix.env() == :dev do
      "dev"
    else
      "production-hash"
    end
  end
end
