defmodule ScorpiusSonnetWeb.PageHTML do
  @moduledoc """
  主页面渲染模块。

  此模块包含由 PageController 渲染的所有页面模板。
  所有模板都位于 `page_html` 目录中。
  """
  use ScorpiusSonnetWeb, :html
  alias ScorpiusSonnetWeb.Components.UIComponents

  embed_templates "page_html/*"
end
