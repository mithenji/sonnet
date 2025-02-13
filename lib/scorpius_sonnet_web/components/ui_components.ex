defmodule ScorpiusSonnetWeb.Components.UIComponents do
  use Phoenix.Component

  @doc """
  渲染一个特性卡片组件。

  ## 示例

      <.feature_card
        title="Phoenix Framework"
        description="基于 Elixir 的高性能 Web 框架"
      />
  """
  attr :title, :string, required: true, doc: "卡片标题"
  attr :description, :string, required: true, doc: "卡片描述"
  attr :rest, :global, default: %{}, doc: "HTML 属性"

  def feature_card(assigns) do
    ~H"""
    <div class="flex flex-col" {@rest}>
      <dt class="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
        <%= @title %>
      </dt>
      <dd class="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
        <p class="flex-auto"><%= @description %></p>
      </dd>
    </div>
    """
  end

  @doc """
  渲染一个主按钮。

  ## 示例

      <.primary_button
        path={~p"/demos"}
        text="查看演示"
      />
  """
  attr :path, :string, required: true, doc: "按钮链接路径"
  attr :text, :string, required: true, doc: "按钮文本"
  attr :rest, :global, default: %{}, doc: "HTML 属性"

  def primary_button(assigns) do
    ~H"""
    <.link
      navigate={@path}
      class={[
        "rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm",
        "hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2",
        "focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
      ]}
      {@rest}
    >
      <%= @text %>
    </.link>
    """
  end

  @doc """
  渲染一个次要按钮。

  ## 示例

      <.secondary_button
        path="https://github.com/your-repo"
        text="了解更多"
      />
  """
  attr :path, :string, required: true, doc: "按钮链接路径"
  attr :text, :string, required: true, doc: "按钮文本"
  attr :rest, :global, default: %{}, doc: "HTML 属性"

  def secondary_button(assigns) do
    ~H"""
    <a href={@path} class="text-sm font-semibold leading-6 text-gray-900" {@rest}>
      <%= @text %> <span aria-hidden="true">→</span>
    </a>
    """
  end

  @doc """
  渲染一个演示项目卡片。

  ## 示例

      <.demo_card
        title="React 演示"
        description="React 18 示例项目"
        path={~p"/demos/react-demo"}
      />
  """
  attr :title, :string, required: true, doc: "卡片标题"
  attr :description, :string, required: true, doc: "卡片描述"
  attr :path, :string, required: true, doc: "卡片链接路径"
  attr :rest, :global, default: %{}, doc: "HTML 属性"

  def demo_card(assigns) do
    ~H"""
    <div class="demo-card" {@rest}>
      <.link
        navigate={@path}
        class="block p-6 bg-white rounded-lg shadow hover:shadow-lg transition duration-200"
      >
        <h2 class="text-xl font-semibold mb-2"><%= @title %></h2>
        <p class="text-gray-600"><%= @description %></p>
      </.link>
    </div>
    """
  end

  @doc """
  渲染一个页面标题。

  ## 示例

      <.page_title
        title="现代 Web 开发的完整解决方案"
        subtitle="快速开发"
        align="center"
      />
  """
  attr :title, :string, required: true, doc: "标题文本"
  attr :subtitle, :string, default: nil, doc: "副标题文本"
  attr :align, :string, default: "center", values: ["left", "center", "right"], doc: "文本对齐方式"

  def page_title(assigns) do
    ~H"""
    <div class={[
      "mx-auto max-w-2xl",
      case @align do
        "left" -> "lg:text-left"
        "right" -> "lg:text-right"
        _ -> "lg:text-center"
      end
    ]}>
      <%= if @subtitle do %>
        <h2 class="text-base font-semibold leading-7 text-indigo-600"><%= @subtitle %></h2>
      <% end %>
      <p class="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
        <%= @title %>
      </p>
    </div>
    """
  end

  @doc """
  渲染一个导航栏。

  ## 示例

      <.nav_bar
        items={[
          %{path: ~p"/demos", text: "首页"},
          %{path: ~p"/demos/about", text: "关于"}
        ]}
        current_path={~p"/demos"}
      />
  """
  attr :items, :list, required: true, doc: "导航项列表，每项需要包含 path 和 text"
  attr :current_path, :string, required: true, doc: "当前页面路径"

  def nav_bar(assigns) do
    ~H"""
    <nav class="flex gap-4">
      <%= for item <- @items do %>
        <.link
          navigate={item.path}
          class={[
            "transition-colors duration-200",
            item.path == @current_path && "text-indigo-600 hover:text-indigo-500",
            item.path != @current_path && "text-gray-600 hover:text-gray-500"
          ]}
        >
          <%= item.text %>
        </.link>
      <% end %>
    </nav>
    """
  end

  @doc """
  渲染一个页面容器。

  ## 示例

      <.page_container class="bg-gray-50">
        <p>容器内容</p>
      </.page_container>
  """
  attr :class, :string, default: nil, doc: "额外的 CSS 类"
  slot :inner_block, required: true, doc: "容器内容"

  def page_container(assigns) do
    ~H"""
    <div class={["container mx-auto px-4 py-8", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  渲染一个页面区块。

  ## 示例

      <.section background="bg-white/80" class="py-24">
        内容
      </.section>
  """
  attr :class, :string, default: nil, doc: "额外的 CSS 类"
  attr :background, :string, default: nil, doc: "背景样式"
  slot :inner_block, required: true, doc: "区块内容"

  def section(assigns) do
    ~H"""
    <section class={["relative", @background, @class]}>
      <%= render_slot(@inner_block) %>
    </section>
    """
  end
end
