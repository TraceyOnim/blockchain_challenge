# TransChain

## Testing in Development Environment

In order to test in development environment, I used (Geth)[https://geth.ethereum.org/docs/getting-start] Ethereum client to turn my computer into Ethereum node. It will connect the computer to the Ethereum network.

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

 4. Fund the account generated in `step 1` using (faucet)[https://fauceth.komputing.org/?chain=1115511]
 

### Interacting with Blockchain
### 1. Setting Up
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
#### Ethereum Blockchain
1. Transaction object for Ethereum Blockchain

Request Object for issuing a transaction

```
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

%{
  id: 1,
  jsonrpc: "2.0",
  method: "eth_sendTransaction",
  params: [
    %{
      data: "0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f072445675",
      from: "0x85a8c4ac888f85a90Ee234ea820A8184a3b14a59",
      gas: "0x76c0",
      gasPrice: "0x9184e72a000",
      to: "0xe27cD333167C923138B7312d946FF249d70fEB2a",
      value: "0x9184e72a"
    }
  ]
}


```

Response Object

```
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "raw": "0xf88380018203339407a565b7ed7d7a678680a4c162885bedbb695fe080a44401a6e4000000000000000000000000000000000000000000000000000000000000001226a0223a7c9bcf5531c99be5ea7082183816eb20cfe0bbc322e97cc5c7f71ab8b20ea02aadee6b34b45bb15bc42d9c09de4a6754e7000908da72d48cc7704971491663",
    "tx": {
      "nonce": "0x0",
      "maxFeePerGas": "0x1234",
      "maxPriorityFeePerGas": "0x1234",
      "gas": "0x55555",
      "to": "0x07a565b7ed7d7a678680a4c162885bedbb695fe0",
      "value": "0x1234",
      "input": "0xabcd",
      "v": "0x26",
      "r": "0x223a7c9bcf5531c99be5ea7082183816eb20cfe0bbc322e97cc5c7f71ab8b20e",
      "s": "0x2aadee6b34b45bb15bc42d9c09de4a6754e7000908da72d48cc7704971491663",
      "hash": "0xeba2df809e7a612a0a0d444ccfa5c839624bdc00dd29e3340d46df3870f8a30e"
    }
  }
}

```
2. Request object for getting info of a transaction

  ```
  params: ["0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b"]

  ```

  ```
  // Request
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":["0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b"],"id":1}'
// Result
{
  "jsonrpc":"2.0",
  "id":1,
  "result":{
    "blockHash":"0x1d59ff54b1eb26b013ce3cb5fc9dab3705b415a67127a003c3e61eb445bb8df2",
    "blockNumber":"0x5daf3b", // 6139707
    "from":"0xa7d9ddbe1f17865597fbd27ec712455208b6b76d",
    "gas":"0xc350", // 50000
    "gasPrice":"0x4a817c800", // 20000000000
    "hash":"0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b",
    "input":"0x68656c6c6f21",
    "nonce":"0x15", // 21
    "to":"0xf02c1c8e6114b1dbe8937a39260b5b0a374432bb",
    "transactionIndex":"0x41", // 65
    "value":"0xf3dbb76162000", // 4290000000000000
    "v":"0x25", // 37
    "r":"0x1b5e176d927f8e9ab405058b2d2457392da3e20f328b16ddabcebc33eaac5fea",
    "s":"0x4ba69724e8f69de52f0125ad8b3c5c2cef33019bac3249e2c0a2192766d1721c"
  }
}

  ```