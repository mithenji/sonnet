ExUnit.start()

# 只在使用数据库时启用 Sandbox 模式
if Code.ensure_loaded?(Ecto.Adapters.SQL.Sandbox) do
  Ecto.Adapters.SQL.Sandbox.mode(ScorpiusSonnet.Repo, :manual)
end
