defmodule MimicryApi.Errors do
	def make_errors_from_openapi_validation(errors) do
		errors |> Enum.map(fn { msg, path } -> %{ path => msg} end)
	end
end