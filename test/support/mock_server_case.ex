defmodule Mimicry.MockServerCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Mimicry.MockServerList
  alias Mimicry.Utils.{SpecificationFileReader, SpecificationFolder}

  def add_server(file_name) do
    {:ok, file} =
      SpecificationFolder.base_path()
      |> Path.join(file_name)
      |> File.read()

    extension = SpecificationFileReader.extension(file_name)

    spec = file |> SpecificationFileReader.load_into_spec(extension)

    MockServerList.create_server(spec)
  end

  setup context do
    file_name = context |> Map.get(:server, false)

    if file_name do
      {:ok, server_pid} = add_server(file_name)

      on_exit(fn ->
        MockServerList.delete_server(server_pid)
      end)
    end

    :ok
  end
end
