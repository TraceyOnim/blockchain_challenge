defmodule TransChain.Client do
  @behaviour TransChain.ClientBehaviour

  def post!(params, method) do
    url() |> HTTPoison.post!(body(params, method), headers())
  end

  defp body(params, method) do
    %{
      id: 1,
      jsonrpc: "2.0",
      method: method,
      params: params
    }
    |> Poison.encode!()
  end

  defp headers do
    [{"content-Type", "application/json"}]
  end

  defp url do
    Application.get_env(:trans_chain, :ethereum_url)
  end
end
