defmodule Mimicry.MockServerCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Mimicry.MockServerList
  alias Mimicry.OpenAPI.Parser
  alias Mimicry.Utils.SpecificationFolder

  @doc """
  used to add a single server by using the

  ```
  @tag server: "<specification-file>"
  test "my awesome test"
  ```

  Essentially enables creation of a single server for a single test
  """
  def add_server(file_name) do
    {:ok, file} =
      SpecificationFolder.base_path()
      |> Path.join(file_name)
      |> File.read()

    extension =
      Path.extname(file_name)
      |> case do
        ".yaml" -> :yaml
        ".json" -> :json
      end

    spec = file |> Parser.parse(extension)

    MockServerList.create_server(spec)
  end

  @doc """
  used to clear all servers from the list, before adding the one used for testing
  """
  def clear_servers, do: MockServerList.clear_servers()

  setup context do
    file_name = context |> Map.get(:server, false)

    if file_name do
      :ok = clear_servers()
      {:ok, server_pid} = add_server(file_name)

      on_exit(fn ->
        MockServerList.delete_server(server_pid)
      end)
    end

    :ok
  end
end
