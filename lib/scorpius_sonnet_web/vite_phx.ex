defmodule VitePhx do
  @moduledoc """
  提供 Vite 资源路径处理的辅助函数，支持多入口和灵活配置
  """

  @doc """
  根据入口名称和类型获取资源路径

  ## 参数
    - entry: 入口文件名称，例如 "demos/counter"
    - type: 资源类型，可选值 :js, :css, :media，默认为 :js

  ## 示例
      iex> VitePhx.asset_path("demos/counter")
      "/demos/counter/counter-DxTXhYaP.js"  # 生产环境
      "http://localhost:5173/demos/counter/main.js"  # 开发环境
  """
  def asset_path(entry, type \\ :js) do
    if Mix.env() == :dev do
      # 开发环境：直接使用开发服务器
      entry_file = ViteConfig.get_entry_config(entry, type_to_entry_key(type))

      "#{ViteConfig.dev_server_url()}/#{entry}/#{entry_file}"
    else
      # 生产环境：优先从 manifest 获取路径
      entry_file = ViteConfig.get_entry_config(entry, type_to_entry_key(type))
      manifest_key = "#{entry}/#{entry_file}"

      case get_manifest_entry(manifest_key) do
        nil ->
          # 如果 manifest 中没有找到，则使用配置系统构建路径
          ViteConfig.build_path(entry, type)

        manifest_entry ->
          # 使用 manifest 中的文件路径
          "/#{manifest_entry["file"]}"
      end
    end
  end

  # 将资源类型转换为配置键
  defp type_to_entry_key(type) do
    case type do
      :js -> :js_entry
      :css -> :css_entry
      _ -> :js_entry
    end
  end

  @doc """
  在开发环境中注入 Vite 客户端脚本
  """
  def vite_client(_module \\ "demos") do
    if Mix.env() == :dev do
      ~s(<script type="module" src="#{ViteConfig.dev_server_url()}/@vite/client"></script>)
    end
  end

  @doc """
  获取资源的manifest路径
  """
  def manifest_path do
    Path.join(Application.app_dir(:scorpius_sonnet, "priv/static"), ".vite/manifest.json")
  end

  @doc """
  读取manifest文件并解析资源路径
  """
  def get_manifest_entry(entry) do
    try do
      manifest_path()
      |> File.read!()
      |> Jason.decode!()
      |> Map.get(entry)
    rescue
      _ -> nil
    end
  end

  @doc """
  根据模式在manifest中查找匹配的文件
  """
  def find_in_manifest_by_pattern(pattern) do
    try do
      manifest = manifest_path() |> File.read!() |> Jason.decode!()

      # 查找所有键，找到匹配的模式
      manifest
      |> Map.keys()
      |> Enum.find(fn key ->
        file = Map.get(manifest[key], "file", "")
        String.contains?(file, pattern)
      end)
      |> case do
        nil ->
          # 如果没有找到，尝试直接在文件系统中查找
          find_in_filesystem(pattern)

        key ->
          # 返回实际文件路径
          "/#{manifest[key]["file"]}"
      end
    rescue
      _ ->
        # 出错时尝试在文件系统中查找
        find_in_filesystem(pattern)
    end
  end

  # 在文件系统中查找匹配的文件
  defp find_in_filesystem(pattern) do
    static_dir = Application.app_dir(:scorpius_sonnet, "priv/static")
    pattern_with_ext = "#{pattern}-*.js"

    case Path.wildcard(Path.join(static_dir, pattern_with_ext)) do
      [] ->
        # 没有找到匹配的文件，返回默认路径
        "/#{pattern}.js"

      [file | _] ->
        # 找到匹配的文件，返回相对路径
        "/" <> Path.relative_to(file, static_dir)
    end
  end

  @doc """
  获取CSS资源路径
  """
  def css_path(entry) do
    asset_path(entry, :css)
  end

  @doc """
  获取媒体资源路径
  """
  def media_path(entry) do
    asset_path(entry, :media)
  end

  @doc """
  获取入口所需的核心库列表

  ## 参数
    - entry: 入口路径，例如 "demos/react-demo"

  ## 示例
      iex> VitePhx.get_entry_core_libs("demos/react-demo")
      ["core-react"]
  """
  def get_entry_core_libs(entry) do
    ViteConfig.get_entry_config(entry, :core_libs) || []
  end

  @doc """
  获取核心库资源路径

  ## 参数
    - lib_name: 核心库名称，例如 "core-react", "core-vue"

  ## 示例
      iex> VitePhx.core_lib_path("core-react")
      "/assets/core/core-react-pQKMmHlK.js"  # 生产环境
      nil  # 开发环境
  """
  def core_lib_path(lib_name) do
    config = ViteConfig.get_core_lib_config(lib_name)
    special_config = ViteConfig.get_special_path(lib_name)

    # 开发环境下返回 nil 或开发路径
    if Mix.env() == :dev do
      get_dev_path(special_config, config)
    else
      get_prod_path(lib_name, special_config, config)
    end
  end

  # 获取开发环境路径
  defp get_dev_path(special_config, config) do
    if special_config, do: special_config.dev_path, else: config.dev_path
  end

  # 获取生产环境路径
  defp get_prod_path(lib_name, special_config, config) do
    # 优先从 manifest 获取路径
    case get_manifest_entry("#{lib_name}.js") do
      nil -> get_fallback_path(special_config, config, lib_name)
      manifest_entry -> "/#{manifest_entry["file"]}"
    end
  end

  # 获取备用路径（当 manifest 中没有找到时）
  defp get_fallback_path(special_config, config, _lib_name) do
    if special_config do
      special_config.prod_path
    else
      find_in_manifest_by_pattern(config.path)
    end
  end

  @doc """
  获取包资源路径

  ## 参数
    - package_name: 包名称，例如 "swiper", "lodash"

  ## 示例
      iex> VitePhx.package_path("swiper")
      "/assets/packages/swiper/index-J1yjBkyn.js"  # 生产环境
      nil  # 开发环境
  """
  def package_path(package_name) do
    config = ViteConfig.get_package_config(package_name)

    # 开发环境下返回 nil 或开发路径
    if Mix.env() == :dev do
      config.dev_path
    else
      # 生产环境：优先使用配置中的 prod_path
      if Map.has_key?(config, :prod_path) do
        config.prod_path
      else
        # 尝试从目录中查找匹配的文件
        find_in_manifest_by_pattern(config.path)
      end
    end
  end

  @doc """
  获取任意资源文件路径

  ## 参数
    - file_pattern: 文件模式，例如 "assets/core/core-react", "assets/packages/swiper/index"
    - dev_path: 开发环境下的路径，如果不提供则尝试从 file_pattern 推断

  ## 示例
      iex> VitePhx.get_asset_file("assets/core/core-react")
      "/assets/core/core-react-pQKMmHlK.js"  # 生产环境
      nil  # 开发环境
  """
  def get_asset_file(file_pattern, dev_path \\ nil) do
    # 开发环境下返回 nil 或开发路径
    if Mix.env() == :dev do
      if dev_path do
        "#{ViteConfig.dev_server_url()}/#{dev_path}"
      else
        nil
      end
    else
      # 生产环境：尝试查找匹配的文件
      find_in_manifest_by_pattern(file_pattern)
    end
  end

  @doc """
  获取共享资源文件路径

  ## 示例
      iex> VitePhx.shared_lib_path()
      "/assets/shared/index-cUMmR5Pg.js"  # 生产环境
  """
  def shared_lib_path do
    get_asset_file("assets/shared/index", "shared.js")
  end

  @doc """
  生成脚本标签，只有在路径存在时才生成

  ## 参数
    - path_func: 获取路径的函数，例如 fn -> VitePhx.core_lib_path("core-react") end
    - attributes: 额外的HTML属性，默认为 %{type: "module"}

  ## 示例
      iex> VitePhx.script_tag_if_exists(fn -> VitePhx.core_lib_path("core-react") end)
      {:safe, "<script type=\\"module\\" src=\\"/assets/core/core-react-pQKMmHlK.js\\"></script>"}  # 生产环境
      {:safe, ""}  # 开发环境
  """
  def script_tag_if_exists(path_func, attributes \\ %{type: "module"}) do
    case path_func.() do
      nil ->
        {:safe, ""}

      path ->
        attrs = build_html_attributes(attributes)
        {:safe, "<script #{attrs} src=\"#{path}\"></script>"}
    end
  end

  # 构建 HTML 属性字符串，将属性映射转换为格式化的字符串
  # 例如：%{type: "module", src: "path"} -> 'type="module" src="path"'
  defp build_html_attributes(attributes) do
    Enum.map_join(attributes, " ", fn {key, value} -> "#{key}=\"#{value}\"" end)
  end

  @doc """
  生成多个核心库的脚本标签

  ## 参数
    - lib_names: 核心库名称列表，例如 ["core-react", "core-vue"]
    - attributes: 额外的HTML属性，默认为 %{type: "module"}

  ## 示例
      iex> VitePhx.core_libs_script_tags(["core-react", "core-vue"])
      {:safe, "<script type=\\"module\\" src=\\"/assets/core/core-react-pQKMmHlK.js\\"></script><script type=\\"module\\" src=\\"/assets/core/core-vue-DLuVOXLq.js\\"></script>"}  # 生产环境
      {:safe, ""}  # 开发环境
  """
  def core_libs_script_tags(lib_names, attributes \\ %{type: "module"}) do
    tags =
      lib_names
      |> Enum.map(&build_core_lib_tag(&1, attributes))
      |> Enum.filter(&(&1 != ""))
      |> Enum.join("")

    {:safe, tags}
  end

  # 构建单个核心库的脚本标签
  # 如果核心库路径不存在则返回空字符串，否则返回完整的 script 标签
  defp build_core_lib_tag(lib_name, attributes) do
    case core_lib_path(lib_name) do
      nil -> ""
      path -> "<script #{build_html_attributes(attributes)} src=\"#{path}\"></script>"
    end
  end

  @doc """
  生成入口所需的所有核心库脚本标签

  ## 参数
    - entry: 入口路径，例如 "demos/react-demo"
    - attributes: 额外的HTML属性，默认为 %{type: "module"}

  ## 示例
      iex> VitePhx.entry_core_libs_tags("demos/react-demo")
      {:safe, "<script type=\\"module\\" src=\\"/assets/core/core-react-pQKMmHlK.js\\"></script>"}  # 生产环境
      {:safe, ""}  # 开发环境
  """
  def entry_core_libs_tags(entry, attributes \\ %{type: "module"}) do
    entry
    |> get_entry_core_libs()
    |> core_libs_script_tags(attributes)
  end

  @doc """
  生成任意资源的HTML标签

  ## 参数
    - path_func: 获取路径的函数，例如 fn -> VitePhx.core_lib_path("core-react") end
    - tag_type: 标签类型，例如 :script, :link
    - attributes: 额外的HTML属性

  ## 示例
      iex> VitePhx.resource_tag(fn -> VitePhx.core_lib_path("core-react") end, :script, %{type: "module"})
      {:safe, "<script type=\\"module\\" src=\\"/assets/core/core-react-pQKMmHlK.js\\"></script>"}  # 生产环境
      {:safe, ""}  # 开发环境

      iex> VitePhx.resource_tag(fn -> VitePhx.css_path("demos/react-demo") end, :link, %{rel: "stylesheet"})
      {:safe, "<link rel=\\"stylesheet\\" href=\\"/demos/react-demo/App-B49DcJcN.css\\">"}
  """
  def resource_tag(path_func, tag_type, attributes) do
    case path_func.() do
      nil ->
        {:safe, ""}

      path ->
        attrs = build_html_attributes(attributes)
        tag_content = build_tag_content(tag_type, attrs, path)
        {:safe, tag_content}
    end
  end

  # 根据标签类型构建 HTML 标签内容
  # 支持 :script 和 :link 类型，其他类型返回空字符串
  defp build_tag_content(tag_type, attrs, path) do
    case tag_type do
      :script -> "<script #{attrs} src=\"#{path}\"></script>"
      :link -> "<link #{attrs} href=\"#{path}\">"
      _ -> ""
    end
  end

  @doc """
  生成入口所需的CSS资源标签，用于放置在<head>标签中

  ## 参数
    - entry: 入口路径，例如 "demos/react-demo"

  ## 示例
      iex> VitePhx.entry_css_tags("demos/react-demo")
      {:safe, "<link rel=\"stylesheet\" href=\"/demos/react-demo/styles.css\">"}
  """
  def entry_css_tags(entry) do
    css_tag = resource_tag(fn -> css_path(entry) end, :link, %{rel: "stylesheet"})
    css_tag
  end

  @doc """
  生成入口所需的JavaScript资源标签，包括核心库，用于放置在<body>底部

  ## 参数
    - entry: 入口路径，例如 "demos/react-demo"
    - options: 选项，例如 %{include_core_libs: true}

  ## 示例
      iex> VitePhx.entry_javascript_tags("demos/react-demo")
      {:safe, "<script type=\"module\" src=\"/assets/core/core-react.js\"></script><script type=\"module\" src=\"/demos/react-demo/main.js\"></script>"}
  """
  def entry_javascript_tags(entry, options \\ %{}) do
    opts = Map.merge(%{include_core_libs: true}, options)

    tags = []

    # 添加核心库标签
    tags =
      if opts.include_core_libs do
        core_libs_tag = entry_core_libs_tags(entry)

        case core_libs_tag do
          {:safe, ""} -> tags
          {:safe, content} -> [content | tags]
        end
      else
        tags
      end

    # 添加 JavaScript 标签
    js_tag = "<script type=\"module\" src=\"#{asset_path(entry)}\"></script>"
    tags = [js_tag | tags]

    # 返回所有标签
    {:safe, Enum.reverse(tags) |> Enum.join("\n")}
  end

  @doc """
  生成入口所需的所有资源标签（向后兼容）

  ## 参数
    - entry: 入口路径，例如 "demos/react-demo"
    - options: 选项，例如 %{include_css: true, include_js: true, include_core_libs: true}

  ## 示例
      iex> VitePhx.entry_tags("demos/react-demo")
      {:safe, "...所有资源标签..."}
  """
  def entry_tags(entry, options \\ %{}) do
    opts =
      Map.merge(
        %{
          include_css: true,
          include_js: true,
          include_core_libs: true
        },
        options
      )

    tags = []

    # 添加 CSS 标签
    tags =
      if opts.include_css do
        css_tag = resource_tag(fn -> css_path(entry) end, :link, %{rel: "stylesheet"})

        case css_tag do
          {:safe, ""} -> tags
          {:safe, content} -> [content | tags]
        end
      else
        tags
      end

    # 添加核心库标签
    tags =
      if opts.include_core_libs do
        core_libs_tag = entry_core_libs_tags(entry)

        case core_libs_tag do
          {:safe, ""} -> tags
          {:safe, content} -> [content | tags]
        end
      else
        tags
      end

    # 添加 JavaScript 标签
    tags =
      if opts.include_js do
        js_tag = "<script type=\"module\" src=\"#{asset_path(entry)}\"></script>"
        [js_tag | tags]
      else
        tags
      end

    # 返回所有标签
    {:safe, Enum.reverse(tags) |> Enum.join("\n")}
  end
end
