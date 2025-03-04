defmodule ScorpiusSonnetWeb.MainHTML.MainHTML do
  @moduledoc """
  主页面渲染模块。

  此模块包含由 MainController 渲染的所有页面模板。
  所有模板都位于 `main_html` 目录中。
  """
  use ScorpiusSonnetWeb, :html
  alias ScorpiusSonnetWeb.Components.UIComponents

  def home(assigns) do
    ~H"""
    <.flash_group flash={@flash} />

    <%!-- 背景装饰 --%>
    <div class="fixed inset-0 -z-10 overflow-hidden">
      <svg
        viewBox="0 0 1480 957"
        fill="none"
        aria-hidden="true"
        class="absolute"
        preserveAspectRatio="xMinYMid slice"
      >
        <path fill="#EE7868" d="M0 0h1480v957H0z" />
        <path
          d="M137.542 466.27c-582.851-48.41-988.806-82.127-1608.412 658.2l67.39 810 3083.15-256.51L1535.94-49.622l-98.36 8.183C1269.29 281.468 734.115 515.799 146.47 467.012l-8.928-.742Z"
          fill="#FF9F92"
        />
        <path
          d="M371.028 528.664C-169.369 304.988-545.754 149.198-1361.45 665.565l-182.58 792.025 3014.73 694.98 389.42-1689.25-96.18-22.171C1505.28 697.438 924.153 757.586 379.305 532.09l-8.277-3.426Z"
          fill="#FA8372"
        />
        <path
          d="M359.326 571.714C-104.765 215.795-428.003-32.102-1349.55 255.554l-282.3 1224.596 3047.04 722.01 312.24-1354.467C1411.25 1028.3 834.355 935.995 366.435 577.166l-7.109-5.452Z"
          fill="#E96856"
          fill-opacity=".6"
        />
        <path
          d="M1593.87 1236.88c-352.15 92.63-885.498-145.85-1244.602-613.557l-5.455-7.105C-12.347 152.31-260.41-170.8-1225-131.458l-368.63 1599.048 3057.19 704.76 130.31-935.47Z"
          fill="#C42652"
          fill-opacity=".2"
        />
        <path
          d="M1411.91 1526.93c-363.79 15.71-834.312-330.6-1085.883-863.909l-3.822-8.102C72.704 125.95-101.074-242.476-1052.01-408.907l-699.85 1484.267 2837.75 1338.01 326.02-886.44Z"
          fill="#A41C42"
          fill-opacity=".2"
        />
        <path
          d="M1116.26 1863.69c-355.457-78.98-720.318-535.27-825.287-1115.521l-1.594-8.816C185.286 163.833 112.786-237.016-762.678-643.898L-1822.83 608.665 571.922 2635.55l544.338-771.86Z"
          fill="#A41C42"
          fill-opacity=".2"
        />
      </svg>
    </div>

    <%!-- 主要内容 --%>
    <div class="relative">
      <%!-- Hero Section --%>
      <UIComponents.section class="px-6 lg:px-8">
        <div class="mx-auto max-w-2xl py-32 sm:py-48 lg:py-56">
          <div class="text-center">
            <UIComponents.page_title title="Scorpius Sonnet" subtitle="现代 Web 开发框架" />
            <p class="mt-6 text-lg leading-8 text-gray-600">
              一个现代的 Web 应用程序框架，基于 Phoenix 和 Elixir 构建
            </p>
            <div class="mt-10 flex items-center justify-center gap-x-6">
              <UIComponents.primary_button path={~p"/demos"} text="查看演示" />
              <UIComponents.secondary_button path="https://github.com/your-repo" text="了解更多" />
            </div>
          </div>
        </div>
      </UIComponents.section>

      <%!-- Features Section --%>
      <UIComponents.section background="bg-white/80 backdrop-blur-sm" class="py-24 sm:py-32">
        <UIComponents.page_container>
          <UIComponents.page_title
            title="现代 Web 开发的完整解决方案"
            subtitle="快速开发"
          />
          <div class="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-none">
            <dl class="grid max-w-xl grid-cols-1 gap-x-8 gap-y-16 lg:max-w-none lg:grid-cols-3">
              <UIComponents.feature_card
                title="Phoenix Framework"
                description="基于 Elixir 的高性能 Web 框架，提供实时通信能力"
              />
              <UIComponents.feature_card
                title="现代前端技术"
                description="集成 Vue、React 等现代前端框架，提供最佳开发体验"
              />
              <UIComponents.feature_card
                title="开箱即用"
                description="内置多个实用的演示项目，帮助你快速上手"
              />
            </dl>
          </div>
        </UIComponents.page_container>
      </UIComponents.section>
    </div>
    """
  end
end
