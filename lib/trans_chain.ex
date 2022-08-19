defprotocol TransChain do
  def transaction(params)
end

alias TransChain.Ethereum

defimpl TransChain, for: Ethereum do
  def transaction(%Ethereum{method: "eth_sendTransaction"} = params) do
    Ethereum.send_transaction(params)
  end

  def transaction(%Ethereum{method: "eth_getTransactionByHash"} = params) do
    Ethereum.get_transaction(params)
  end
end

# defimpl TransChain, for: Ethereum do
#   def transaction(params), do: Ethereum.get_transaction(params)
# end

# defimpl TransChain, for: Bitcoin do
#   def send_transaction(params), do: Bitcoin.send_transaction()
# end
