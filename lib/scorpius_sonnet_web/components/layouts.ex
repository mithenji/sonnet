defmodule ScorpiusSonnetWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use ScorpiusSonnetWeb, :controller` and
  `use ScorpiusSonnetWeb, :live_view`.
  """
  use ScorpiusSonnetWeb, :html

  embed_templates "layouts/*"

  # 辅助函数
  def get_asset_hash do
    if Mix.env() == :dev do
      "dev"
    else
      "production-hash"
    end
  end
end
