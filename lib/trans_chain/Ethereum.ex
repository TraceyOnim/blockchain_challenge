defmodule TransChain.Ethereum do
  @moduledoc """
  This module is responsible for manipulating functionality involved for Ethereum blockchain
  """
  require Logger
  alias __MODULE__

  @type t :: %Ethereum{params: [any()], method: String.t()}

  defstruct ~w(params method)a

  def send_transaction(%__MODULE__{params: params, method: method}) do
    url()
    |> HTTPoison.post!(body(params, method), headers())
    |> response()
  end

  def get_transaction(%__MODULE__{params: params, method: method}) do
    url()
    |> HTTPoison.post!(body(params, method), headers())
    |> transaction_info()
  end

  defp transaction_info(%HTTPoison.Response{body: body, status_code: 200}) do
    case Poison.decode!(body) do
      %{"result" => nil} ->
        IO.puts("No matching transaction")

      %{"result" => result} ->
        Enum.each(result, fn {k, v} -> IO.puts("#{k}:  #{v}") end)
    end
  end

  defp transaction_info(_) do
    Logger.error("Failed to fetch transaction info, Try Again!!")
  end

  defp response(%HTTPoison.Response{body: body, status_code: 200}) do
    case Poison.decode!(body) do
      %{"result" => %{"tx" => tx}} ->
        Logger.info("complete successfully")
        Logger.info("Transaction hash" <> ":" <> "#{tx["hash"]}")
        Logger.info("Transaction gas" <> ":" <> "#{tx["gas"]}")

      %{"error" => %{"message" => message}} ->
        Logger.error(message)
    end
  end

  defp response(_) do
    Logger.error("Failed to issue transaction, Try Again!!")
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
