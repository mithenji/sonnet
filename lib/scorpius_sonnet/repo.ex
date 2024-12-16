defmodule ScorpiusSonnet.Repo do
  use Ecto.Repo,
    otp_app: :scorpius_sonnet,
    adapter: Ecto.Adapters.Postgres
end
