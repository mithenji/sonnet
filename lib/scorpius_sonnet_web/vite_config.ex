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

  # 定义入口配置
  def entry_configs do
    %{
      # 演示入口配置
      "demos" => %{
        # 子入口配置
        "react-demo" => %{
          js_entry: "main.jsx",
          css_entry: "App.css",
          core_libs: ["core-react"],
          # 路径构建规则
          path_rules: %{
            js: "/demos/react-demo/main",
            css: "/demos/react-demo/App"
          }
        },
        "counter" => %{
          js_entry: "main.js",
          css_entry: "styles/index.css",
          # 路径构建规则
          path_rules: %{
            js: "/demos/counter/main",
            css: "/demos/counter/styles/index"
          }
        },
        "christmas-meta" => %{
          js_entry: "main.js",
          css_entry: "styles/index.css",
          # 路径构建规则
          path_rules: %{
            js: "/demos/christmas-meta/main",
            css: "/demos/christmas-meta/styles/index"
          }
        },
        # 默认配置，当没有找到特定子入口配置时使用
        "default" => %{
          js_entry: "main.js",
          css_entry: "styles/index.css",
          # 路径构建规则
          path_rules: %{
            js: fn entry -> "/#{entry}/main" end,
            css: fn entry -> "/#{entry}/styles/index" end
          }
        }
      },
      # 主应用入口配置
      "main" => %{
        "default" => %{
          js_entry: "main.js",
          css_entry: "styles/index.css",
          # 路径构建规则
          path_rules: %{
            js: fn entry, sub_entry -> "/#{entry}/#{sub_entry}" end,
            css: fn entry, sub_entry -> "/#{entry}/styles/#{sub_entry}" end
          }
        }
      },
      # 默认入口配置，当没有找到特定入口配置时使用
      "default" => %{
        js_entry: "main.js",
        css_entry: "styles/index.css",
        # 路径构建规则
        path_rules: %{
          js: fn entry -> "/#{entry}" end,
          css: fn entry -> "/#{entry}" end,
          media: fn entry -> "/assets/images/#{entry}" end
        }
      }
    }
  end

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
    main_config = Map.get(entry_configs(), main_entry, entry_configs()["default"])

    # 获取子入口配置
    sub_config = Map.get(main_config, sub_entry, main_config["default"])

    # 获取特定配置项
    Map.get(sub_config, key)
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
      _ -> nil
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
        build_default_path(main_entry, sub_entry, type)
    end
  end

  # 构建默认路径
  # 根据资源类型生成标准格式的路径
  defp build_default_path(main_entry, sub_entry, type) do
    entry = "#{main_entry}/#{sub_entry}"
    case type do
      :js -> "/#{entry}/main"
      :css -> "/#{entry}/styles/index"
      :media -> "/assets/images/#{entry}"
      _ -> "/#{entry}"
    end
  end
end
