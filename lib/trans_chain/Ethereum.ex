defmodule TransChain.Ethereum do
  @moduledoc """
  This module is responsible for manipulating functionality involved for Ethereum blockchain
  """
  require Logger
  alias TransChain.Client
  alias __MODULE__

  @type t :: %Ethereum{params: [any()], method: String.t()}

  @http_client Application.get_env(:trans_chain, :http_client, Client)

  defstruct ~w(params method)a

  @spec send_transaction(Ethereum.t()) :: :ok
  def send_transaction(%__MODULE__{params: params, method: method}) do
    params
    |> @http_client.post!(method)
    |> response()
  end

  def notify(_) do
    Logger.error("missing param or method")
  end

  @spec send_transaction(Ethereum.t()) :: :ok
  def get_transaction(%__MODULE__{params: params, method: method}) do
    params
    |> @http_client.post!(method)
    |> transaction_info()
  end

  defp transaction_info(%HTTPoison.Response{body: body, status_code: 200}) do
    case Poison.decode!(body) do
      %{"result" => nil} ->
        IO.puts("No matching transaction")

      %{"result" => result} ->
        Enum.each(result, fn {k, v} -> IO.puts("#{k}:  #{v}") end)

      %{"error" => error} ->
        Logger.error(error["message"])
    end
  end

  defp transaction_info(_) do
    Logger.error("Failed to fetch transaction info, Try Again!!")
  end

  defp response(%HTTPoison.Response{body: body, status_code: 200}) do
    case Poison.decode!(body) do
      %{"result" => %{"tx" => tx}} ->
        IO.puts("Transaction completed successfully")
        IO.puts("Transaction hash" <> ":" <> "#{tx["hash"]}")
        IO.puts("Transaction gas" <> ":" <> "#{tx["gas"]}")

      %{"error" => error} ->
        Logger.error(error["message"])
    end
  end

  defp response(_) do
    Logger.error("Failed to issue transaction, Try Again!!")
  end
end
