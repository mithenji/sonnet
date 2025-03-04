defmodule ScorpiusSonnetWeb.Demos.IndexHTML.IndexHTML do
  use ScorpiusSonnetWeb, :html

  alias ScorpiusSonnetWeb.Components.UIComponents
  alias ScorpiusSonnetWeb.DemoComponents

  # 直接定义index函数
  def index(assigns) do
    ~H"""
    <.flash_group flash={@flash} />

    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8 text-center">演示项目列表</h1>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <.demo_card
          title="计数器演示"
          description="使用 Vue 3 构建的简单计数器应用"
          path={~p"/demos/counter"}
        />

        <.demo_card
          title="React 演示"
          description="使用 React 18 构建的示例应用"
          path={~p"/demos/react-demo"}
        />

        <.demo_card
          title="圣诞节特效"
          description="使用 Canvas 和 JavaScript 实现的圣诞节特效"
          path={~p"/demos/christmas"}
        />

        <.demo_card
          title="圣诞节元数据"
          description="圣诞节特效的元数据版本"
          path={~p"/demos/christmas-meta"}
        />
      </div>

      <div class="mt-12 text-center">
        <.secondary_button path={~p"/demos/about"} text="关于演示项目" />
      </div>
    </div>
    """
  end

  # 直接定义about函数
  def about(assigns) do
    ~H"""
    <.flash_group flash={@flash} />

    <div class="container mx-auto px-4 py-8 max-w-3xl">
      <h1 class="text-3xl font-bold mb-8 text-center">关于演示项目</h1>

      <div class="prose prose-lg mx-auto">
        <p>
          Scorpius Sonnet 演示项目是一系列展示如何使用现代前端技术与 Phoenix 框架结合的示例应用。
          这些演示项目旨在帮助开发者了解如何：
        </p>

        <ul class="list-disc pl-6 mt-4 space-y-2">
          <li>在 Phoenix 应用中集成 Vue、React 等前端框架</li>
          <li>使用 Vite 作为前端构建工具</li>
          <li>实现前后端的无缝通信</li>
          <li>构建响应式用户界面</li>
          <li>组织大型应用的代码结构</li>
        </ul>

        <h2 class="text-2xl font-semibold mt-8 mb-4">技术栈</h2>

        <p>这些演示项目使用了以下技术：</p>

        <ul class="list-disc pl-6 mt-4 space-y-2">
          <li>Phoenix 框架 - 后端</li>
          <li>Elixir 编程语言</li>
          <li>Vue 3 - 前端框架</li>
          <li>React 18 - 前端框架</li>
          <li>Vite - 前端构建工具</li>
          <li>TailwindCSS - 样式框架</li>
        </ul>
      </div>

      <div class="mt-12 text-center">
        <.primary_button path={~p"/demos"} text="返回演示列表" />
      </div>
    </div>
    """
  end

  # 导入必要的组件函数
  def demo_card(assigns), do: DemoComponents.demo_card(assigns)
  def primary_button(assigns), do: UIComponents.primary_button(assigns)
  def secondary_button(assigns), do: UIComponents.secondary_button(assigns)
end
