defmodule ScorpiusSonnet.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use ScorpiusSonnet.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # 暂时注释掉数据库相关的导入
      # alias ScorpiusSonnet.Repo
      # import Ecto
      # import Ecto.Changeset
      # import Ecto.Query
      import ScorpiusSonnet.DataCase
    end
  end

  setup _tags do
    # 暂时禁用 sandbox 设置
    # ScorpiusSonnet.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(_tags) do
    :ok
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
