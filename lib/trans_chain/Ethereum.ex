defmodule TransChain.Ethereum do
  @moduledoc """
  This module is responsible for manipulating functionality involved for Ethereum blockchain
  """
   require Logger
  alias __MODULE__

  @type t :: %Ethereum{params: [map()]}

  defstruct ~w(params)a

  def send_transaction(%__MODULE__{params: params}) do
    %HTTPoison.Response{body: body, status_code}=url() |> HTTPoison.post!(body(params), headers())
  end

  defp response(%HTTPoison.Response{body: body, status_code: 200}) do
   case Poison.decode!(body) do
     %{"result" => %{"tx" => tx}} -> 
      Logger.info("Transaction status" <> ":" <> "complete successfully")
      Logger.info("Transaction hash" <> ":" <> "#{tx["hash"]}")
      Logger.info("Transaction gas" <> ":" <> "#{tx["gas"]}")

     %{"error" => %{"message" => message}} -> message
   end

  end

  defp body(params) do
    %{
      id: 1,
      jsonrpc: "2.0",
      method: "eth_sendTransaction",
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
