# TransChain

## 1. Setting Up
- Add `HTTPoison` http client for Elixir to issue http request
    ```elixir
   def deps do
    [
      {:httpoison, "~> 1.8"}
    ]
   end
    ```

- Add `poison` for encoding and decoding `JSON` objects.

    ```elixir
    def deps do
      [{:poison, "~> 5.0"}]
    end
    ```

- Add `mox` to mock external request when testing.

   ```elixir
   def deps do
    {:mox, "~> 1.0", only: :test}
   end
   ```
- Configure `url` that will be used to send request to Ethereum network

    ```
    config :trans_chain,
      ethereum_url: "http://localhost:8545"
    ```

## Design/Implementation Decision
I have created `TransChain protocol` which will be convenience when adding functionality for other chains. Currently this API issues and fetches transaction for `Ethereum blockchain`.

The `TransChain protocol` is implemented for `struct` which are defined inside the context representing each chain. For example 

```elixir
defimpl TransChain, for: Ethereum do
...
end
```
The `Ethereum ` struct is defined inside `TransChain.Ethereum` module. Its fields are `params` and `method`. The  `TransChain.Ethereum` will be responsible for all operations that entails `Ethereum Blockchain`.

Looking at the request objects for `issuing transaction` and `fetching transaction`;

```
#issue transaction object
{
  "id": 2,
  "jsonrpc": "2.0",
  "method": "account_signTransaction",
  "params": [
    {
      "from": "0x1923f626bb8dc025849e00f99c25fe2b2f7fb0db",
      "gas": "0x55555",
      "maxFeePerGas": "0x1234",
      "maxPriorityFeePerGas": "0x1234",
      "input": "0xabcd",
      "nonce": "0x0",
      "to": "0x07a565b7ed7d7a678680a4c162885bedbb695fe0",
      "value": "0x1234"
    }
  ]
}
```

```
#fetch transaction object

{"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":["0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b"],"id":1}
```
You will notice they both have `params` and `method` of the same data type, params(list) and method(string). However, they contain different content. It was only convenient to take in the params and method and execute the required operation.

When issuing transaction, you will invoke the `transaction/1` it takes in `%Ethereum{}` as its parameter:

```elixir
 params = [
        %{
          data:
            "0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f072445675",
          from: "0x85a8c4ac888f85a90Ee234ea820A8184a3b14a59",
          gas: "0x76c0",
          gasPrice: "0x9184e72a000",
          to: "0xe27cD333167C923138B7312d946FF249d70fEB2a",
          value: "0x9184e72a"
        }
      ]

TransChain.transaction(%Ethereum{params: params,method: "eth_sendTransaction"})
```

When fetching transaction, you will also invoke the `transaction/1` it takes in `%Ethereum{}` as its parameter:

```
 params = ["0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b"]

 TransChain.transaction(%Ethereum{params: params, method: "eth_getTransactionByHash"})
```
For successfull transaction ensure required params and method are passed. 

The ` TransChain.Client` module entails the function(s) responsible for broadcasting transaction to a blockchain network.

## Testing in Development Environment

In order to test in development environment, I used [Geth](https://geth.ethereum.org/docs/getting-start) Ethereum client to turn my computer into Ethereum node. It will connect the computer to the Ethereum network.

The following steps were taken:
1. Install Geth https://geth.ethereum.org/docs/install-and-build/installing-geth
2. Generate an Externally Owned Account 
    ```
    $ geth account new --keystore trans-chain-integration/keystore

    ```
 I have provided a custom keystore `trans-chain-integration` where keys will be stored

 3. Start Geth to connect the computer to the Ethereum network(in my case I will use Goerli, Ethereum testnet)

 ```
 geth --datadir trans-chain-integration --goerli --syncmode light --http --http.addr 0.0.0.0

 ```
 `trans-chain-integration` is a directory where `Geth` should save the `blockchain data`

 4. Fund the account generated in `step 1` using [faucet](https://fauceth.komputing.org/?chain=1115511)
 

### Interacting with Ethereum Blockchain

Testing the `transaction/1` in the interactive shell:

```
iex > alias TransChain.Ethereum

iex > params = [
        %{
          data:
            "0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f072445675",
          from: "0x85a8c4ac888f85a90Ee234ea820A8184a3b14a59",
          gas: "0x76c0",
          gasPrice: "0x9184e72a000",
          to: "0xe27cD333167C923138B7312d946FF249d70fEB2a",
          value: "0x9184e72a"
        }
      ]

iex > TransChain.transaction(%Ethereum{params: params,method: "eth_sendTransaction")


iex > Transaction completed successfully
      Transaction hash:0xeba2df809e7a612a0a0d444ccfa5c839624bdc00dd29e3340d46df3870f8a30e
      Transaction gas:0x55555


iex > params = ["0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b"]

iex > TransChain.transaction(%Ethereum{params: params, method: "eth_getTransactionByHash"})

iex > blockHash:  0x1d59ff54b1eb26b013ce3cb5fc9dab3705b415a67127a003c3e61eb445bb8df2
      blockNumber:  0x5daf3b
      from:  0xa7d9ddbe1f17865597fbd27ec712455208b6b76d
      gas:  0xc350
      gasPrice:  0x4a817c800
      hash:  0x89de016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944c
      input:  0x68656c6c6f21
      nonce:  0x15
      r:  0x1b5e176d927f8e9ab405058b2d2457392da3e20f328b16ddabcebc33eaac5fea
      s:  0x4ba69724e8f69de52f0125ad8b3c5c2cef33019bac3249e2c0a2192766d1721c
      to:  0xf02c1c8e6114b1dbe8937a39260b5b0a374432bb
      transactionIndex:  0x41
      v:  0x25
      value:  0xf3dbb76162000



```

## Future Work
1. Integrating with other blockchain's APIs. 
  
#### Steps:
- Familiarize with other blockchains to know the requirements needed.
- Add implementation . I have already created a protocol that will make it easier to add other chains. 
For Example , lets say we want to issue transaction for Bitcoin;
In the `TransChain` protocol, I will add the following implementation

```elixir
defimpl TransChain, for: Bitcoin do
  def send_transaction(params), do: Bitcoin.send_transaction()
end

```

2.Save failed transaction. This will come handy at the point refunds needs to be done.
  Failed transaction can either be stored onto the database or even ets tables.

3. Convert exchange rates to euros.
