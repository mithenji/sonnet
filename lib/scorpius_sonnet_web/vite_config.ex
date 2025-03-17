defmodule ViteConfig do
  @moduledoc """
  Vite 资源配置模块，提供灵活的配置选项
  """

  # 定义开发服务器配置
  def dev_server do
    %{
      host: "localhost",
      port: 5173,
      https: false
    }
  end

  # 缓存扫描结果
  @entry_configs_cache_key :entry_configs_cache

  # 定义入口配置
  def entry_configs do
    # 尝试从缓存获取
    case :persistent_term.get(@entry_configs_cache_key, nil) do
      nil ->
        # 缓存未命中，获取动态配置
        configs = read_or_scan_dynamic_configs()

        # 存入缓存
        :persistent_term.put(@entry_configs_cache_key, configs)
        configs

      configs ->
        # 缓存命中
        configs
    end
  end

  # 读取或扫描动态配置
  defp read_or_scan_dynamic_configs do
    # 获取 priv 目录路径
    priv_dir = Application.app_dir(:scorpius_sonnet, "priv")
    config_path = Path.join(priv_dir, "vite_entries.json")

    cond do
      # 开发环境：每次都扫描
      Mix.env() == :dev ->
        configs = scan_entry_configs()
        # 即使在开发环境，也写入配置文件以便调试
        write_config_file(configs)
        configs

      # 生产环境：优先使用配置文件
      File.exists?(config_path) ->
        IO.puts("读取配置文件: #{config_path}")
        config_path
        |> File.read!()
        |> Jason.decode!(keys: :atoms)

      # 配置文件不存在：执行扫描
      true ->
        IO.puts("配置文件不存在，执行扫描")
        configs = scan_entry_configs()
        write_config_file(configs)
        configs
    end
  end

  # 写入配置文件
  defp write_config_file(configs) do
    # 获取 priv 目录路径
    priv_dir = Application.app_dir(:scorpius_sonnet, "priv")
    config_path = Path.join(priv_dir, "vite_entries.json")

    # 确保 priv 目录存在
    unless File.dir?(priv_dir) do
      IO.puts("创建 priv 目录: #{priv_dir}")
      File.mkdir_p!(priv_dir)
    end

    IO.puts("正在写入配置文件: #{config_path}")
    serializable_configs = make_serializable(configs)

    # 写入配置文件
    case File.write(config_path, Jason.encode!(serializable_configs, pretty: true)) do
      :ok ->
        IO.puts("配置文件已成功写入")
      {:error, reason} ->
        IO.puts("写入配置文件失败: #{inspect(reason)}")
    end
  end

  # 定义要扫描的目录
  def scan_dirs do
    [
      "demos",
      "main"
    ]
  end

  # 扫描入口配置
  defp scan_entry_configs do
    # 直接使用项目根目录下的 assets 目录
    project_root = Path.join(File.cwd!(), "")
    assets_path = Path.join(project_root, "assets")

    IO.puts("使用 assets 目录: #{assets_path}")

    # 检查目录是否存在
    unless File.dir?(assets_path) do
      IO.puts("错误: 找不到 assets 目录: #{assets_path}")
      %{}
    else
      # 获取要扫描的目录列表
      scan_directories = scan_dirs()

      # 只扫描指定的目录
      main_entries =
        scan_directories
        |> Enum.filter(&File.dir?(Path.join(assets_path, &1)))

      IO.puts("扫描以下目录: #{Enum.join(main_entries, ", ")}")

      # 构建配置映射
      main_entries
      |> Enum.reduce(%{}, fn main_entry, acc ->
        sub_entries = scan_sub_entries(assets_path, main_entry)

        # 只有当子入口不为空时才添加到配置中
        if Enum.empty?(sub_entries) do
          acc
        else
          Map.put(acc, main_entry, sub_entries)
        end
      end)
    end
  end

  # 扫描子入口
  defp scan_sub_entries(assets_path, main_entry) do
    main_path = Path.join(assets_path, main_entry)

    # 扫描子入口目录
    sub_entries =
      main_path
      |> File.ls!()
      |> Enum.filter(&File.dir?(Path.join(main_path, &1)))
      |> Enum.filter(&(not String.starts_with?(&1, ".")))

    IO.puts("在 #{main_entry} 中扫描到子入口: #{Enum.join(sub_entries, ", ")}")

    # 构建子入口配置
    sub_entries
    |> Enum.reduce(%{}, fn sub_entry, acc ->
      config = detect_entry_config(main_path, main_entry, sub_entry)
      Map.put(acc, sub_entry, config)
    end)
  end

  # 检测入口配置
  defp detect_entry_config(main_path, main_entry, sub_entry) do
    entry_path = Path.join(main_path, sub_entry)

    # 检测 JS 入口文件
    js_entry = detect_js_entry(entry_path)

    # 检测 CSS 入口文件
    css_entry = detect_css_entry(entry_path)

    # 检测核心库依赖
    core_libs = detect_core_libs(entry_path)

    # 构建路径规则
    path_rules = build_path_rules(main_entry, sub_entry, js_entry, css_entry)

    # 构建配置
    %{
      js_entry: js_entry,
      css_entry: css_entry,
      core_libs: core_libs,
      path_rules: path_rules
    }
  end

  # 构建路径规则
  defp build_path_rules(main_entry, sub_entry, js_entry, css_entry) do
    js_path = if String.ends_with?(js_entry, ".jsx") or String.ends_with?(js_entry, ".js") do
      "/#{main_entry}/#{sub_entry}/#{Path.rootname(js_entry)}"
    else
      "/#{main_entry}/#{sub_entry}/#{js_entry}"
    end

    css_path = if String.ends_with?(css_entry, ".css") do
      "/#{main_entry}/#{sub_entry}/#{Path.rootname(css_entry)}"
    else
      "/#{main_entry}/#{sub_entry}/#{css_entry}"
    end

    %{
      js: js_path,
      css: css_path
    }
  end

  # 检测 JS 入口文件
  defp detect_js_entry(entry_path) do
    # 按优先级检测常见入口文件名
    cond do
      File.exists?(Path.join(entry_path, "main.jsx")) -> "main.jsx"
      File.exists?(Path.join(entry_path, "main.js")) -> "main.js"
      File.exists?(Path.join(entry_path, "index.jsx")) -> "index.jsx"
      File.exists?(Path.join(entry_path, "index.js")) -> "index.js"
      true -> "main.js" # 默认
    end
  end

  # 检测 CSS 入口文件
  defp detect_css_entry(entry_path) do
    # 按优先级检测常见样式文件
    cond do
      File.exists?(Path.join(entry_path, "App.css")) -> "App.css"
      File.exists?(Path.join(entry_path, "styles/index.css")) -> "styles/index.css"
      File.exists?(Path.join(entry_path, "style.css")) -> "style.css"
      File.exists?(Path.join(entry_path, "index.css")) -> "index.css"
      true -> "styles/index.css" # 默认
    end
  end

  # 检测核心库依赖
  defp detect_core_libs(entry_path) do
    # 读取入口文件内容，分析导入语句
    js_entry = detect_js_entry(entry_path)
    js_path = Path.join(entry_path, js_entry)

    if File.exists?(js_path) do
      content = File.read!(js_path)

      # 检测核心库依赖
      core_libs = []

      # 检测 React
      core_libs = if String.contains?(content, "react") or
                     String.contains?(content, "React") or
                     String.ends_with?(js_entry, ".jsx") do
        ["core-react" | core_libs]
      else
        core_libs
      end

      # 检测 Vue
      core_libs = if String.contains?(content, "vue") or
                     String.contains?(content, "Vue") do
        ["core-vue" | core_libs]
      else
        core_libs
      end

      core_libs
    else
      []
    end
  end

  # 手动刷新缓存的函数
  def refresh_entry_configs do
    dynamic_configs = scan_entry_configs()

    # 存入缓存
    :persistent_term.put(@entry_configs_cache_key, dynamic_configs)

    # 更新配置文件
    write_config_file(dynamic_configs)

    dynamic_configs
  end

  # 提供一个命令行任务来生成配置文件
  def generate_entry_configs_file do
    dynamic_configs = scan_entry_configs()
    write_config_file(dynamic_configs)
    {:ok, "配置文件已更新"}
  end

  # 将配置转换为可序列化格式（移除函数）
  defp make_serializable(config) when is_map(config) do
    config
    |> Enum.map(fn {k, v} -> {k, make_serializable(v)} end)
    |> Enum.into(%{})
  end

  defp make_serializable(config) when is_list(config) do
    Enum.map(config, &make_serializable/1)
  end

  defp make_serializable(v) when is_function(v) do
    "#function"  # 用字符串替代函数
  end

  defp make_serializable(v), do: v

  # 定义资源类型配置
  def resource_types do
    %{
      js: %{
        dev_ext: ".js",
        prod_ext: ".js",
        tag: :script,
        tag_attrs: %{type: "module", src: true}
      },
      css: %{
        dev_ext: ".css",
        prod_ext: ".css",
        tag: :link,
        tag_attrs: %{rel: "stylesheet", href: true}
      },
      media: %{
        dev_ext: "",
        prod_ext: "",
        tag: :img,
        tag_attrs: %{src: true}
      }
    }
  end

  # 定义特殊路径配置
  def special_paths do
    %{
      # 核心库
      "core-react" => %{
        path: "assets/core/core-react",
        # 开发环境下不需要引入
        dev_path: nil,
        prod_path: "/assets/core/core-react"
      },
      "core-vue" => %{
        path: "assets/core/core-vue",
        # 开发环境下不需要引入
        dev_path: nil,
        prod_path: "/assets/core/core-vue"
      },
      # 共享资源
      "shared" => %{
        path: "assets/shared/index",
        dev_path: "shared.js",
        prod_path: %{
          js: "/demos/index/main",
          css: "/demos/index/styles/index"
        }
      }
    }
  end

  # 定义核心库配置
  def core_libs do
    %{
      "core-react" => %{
        path: "assets/core/core-react",
        # 开发环境下不需要引入
        dev_path: nil
      },
      "core-vue" => %{
        path: "assets/core/core-vue",
        # 开发环境下不需要引入
        dev_path: nil
      }
    }
  end

  # 定义包配置
  def packages do
    %{
      "swiper" => %{
        path: "assets/packages/swiper/index",
        # 开发环境下不需要引入
        dev_path: nil,
        prod_path: "/assets/packages/swiper/index"
      },
      "lodash" => %{
        path: "assets/packages/lodash/index",
        # 开发环境下不需要引入
        dev_path: nil,
        prod_path: "/assets/packages/lodash/index"
      }
    }
  end

  # 获取开发服务器URL
  def dev_server_url do
    config = dev_server()
    protocol = if config.https, do: "https", else: "http"
    "#{protocol}://#{config.host}:#{config.port}"
  end

  # 获取入口配置
  def get_entry_config(entry, key) do
    [main_entry | sub_entries] = String.split(entry, "/")

    sub_entry = if length(sub_entries) > 0, do: hd(sub_entries), else: "default"

    # 获取主入口配置
    main_config = Map.get(entry_configs(), main_entry)

    if is_nil(main_config) do
      # 主入口不存在，返回默认值
      get_default_config(key)
    else
      # 获取子入口配置
      sub_config = Map.get(main_config, sub_entry)

      if is_nil(sub_config) do
        # 子入口不存在，返回默认值
        get_default_config(key)
      else
        # 获取特定配置项
        Map.get(sub_config, key)
      end
    end
  end

  # 获取默认配置
  defp get_default_config(key) do
    case key do
      :js_entry -> "main.js"
      :css_entry -> "styles/index.css"
      :core_libs -> []
      :path_rules -> %{
        js: fn entry -> "/#{entry}/main" end,
        css: fn entry -> "/#{entry}/styles/index" end,
        media: fn entry -> "/assets/images/#{entry}" end
      }
      _ -> nil
    end
  end

  # 获取资源类型配置
  def get_resource_type_config(type) do
    Map.get(resource_types(), type, resource_types().js)
  end

  # 获取核心库配置
  def get_core_lib_config(lib_name) do
    Map.get(core_libs(), lib_name, %{path: "assets/core/#{lib_name}", dev_path: nil})
  end

  # 获取包配置
  def get_package_config(package_name) do
    Map.get(packages(), package_name, %{
      path: "assets/packages/#{package_name}/index",
      dev_path: nil
    })
  end

  # 获取特殊路径配置
  def get_special_path(path_name) do
    Map.get(special_paths(), path_name)
  end

  # 构建资源路径
  def build_path(entry, type) do
    build_path_with_rules(entry, type, get_special_path(entry))
  end

  # 处理特殊路径配置
  # 当路径有特殊配置时，直接返回特殊配置的路径
  defp build_path_with_rules(entry, type, special_config) when not is_nil(special_config) do
    case Map.get(special_config, :prod_path) do
      path when is_binary(path) -> path
      path_map when is_map(path_map) -> Map.get(path_map, type, "/#{entry}")
      _ -> "/#{entry}"
    end
  end

  # 处理普通路径配置
  # 将入口路径解析为主入口和子入口，并应用相应的路径规则
  defp build_path_with_rules(entry, type, nil) do
    with [main_entry | sub_entries] <- String.split(entry, "/"),
         sub_entry <- get_sub_entry(sub_entries),
         path_rules when not is_nil(path_rules) <- get_entry_config(entry, :path_rules) do
      build_path_from_rules(main_entry, sub_entry, type, path_rules)
    else
      _ -> build_default_path(entry, type)
    end
  end

  # 获取子入口名称
  # 如果没有子入口则返回 "default"，否则返回第一个子入口
  defp get_sub_entry([]), do: "default"
  defp get_sub_entry([head | _]), do: head

  # 根据路径规则构建最终路径
  # 支持三种规则类型：
  # 1. 单参数函数规则：接收完整入口路径
  # 2. 双参数函数规则：分别接收主入口和子入口
  # 3. 字符串规则：直接作为路径返回
  defp build_path_from_rules(main_entry, sub_entry, type, path_rules) do
    case Map.get(path_rules, type) do
      rule when is_function(rule, 1) ->
        rule.("#{main_entry}/#{sub_entry}")

      rule when is_function(rule, 2) ->
        rule.(main_entry, sub_entry)

      rule when is_binary(rule) ->
        rule

      _ ->
        entry = "#{main_entry}/#{sub_entry}"
        build_default_path(entry, type)
    end
  end

  # 构建默认路径
  # 根据资源类型生成标准格式的路径
  defp build_default_path(entry, type) do
    case type do
      :js -> "/#{entry}/main"
      :css -> "/#{entry}/styles/index"
      :media -> "/assets/images/#{entry}"
      _ -> "/#{entry}"
    end
  end
end
