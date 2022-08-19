defprotocol TransChain do
  def send_transaction(params)
end

alias TransChain.Ethereum

defimpl TransChain, for: Ethereum do
  def send_transaction(params), do: Ethereum.send_transaction(params)
end

# defimpl TransChain, for: Bitcoin do
#   def send_transaction(params), do: Bitcoin.send_transaction()
# end
