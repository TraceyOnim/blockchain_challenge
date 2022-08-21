defmodule TransChain.ClientBehaviour do
  @callback post!(params :: [any()], method :: String.t()) :: Response.t() | AsyncResponse.t()
end
