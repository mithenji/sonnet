   defmodule Mix.Tasks.Vite.GenerateConfig do
     use Mix.Task

     @shortdoc "生成 Vite 入口配置文件"
     def run(_) do
       ViteConfig.generate_entry_configs_file()
       |> IO.inspect()
     end
   end
