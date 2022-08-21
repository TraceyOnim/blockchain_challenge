defmodule TransChainTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  import ExUnit.CaptureLog
  alias TransChain.Ethereum

  describe "Fetch transaction info" do
    setup do
      invalid_arg_response = %HTTPoison.Response{
        body:
          "{\"jsonrpc\":\"2.0\",\"id\":1,\"error\":{\"code\":-32602,\"message\":\"invalid argument 0: json: cannot unmarshal hex string without 0x prefix into Go value of type common.Hash\"}}\n",
        headers: [
          {"Content-Type", "application/json"},
          {"Date", "Sun, 21 Aug 2022 11:02:32 GMT"},
          {"Content-Length", "167"}
        ],
        request: %HTTPoison.Request{
          body:
            "{\"params\":[\"xxx\"],\"method\":\"eth_getTransactionByHash\",\"jsonrpc\":\"2.0\",\"id\":1}",
          headers: [{"content-Type", "application/json"}],
          method: :post,
          options: [],
          params: %{},
          url: "http://localhost:8545"
        },
        request_url: "http://localhost:8545",
        status_code: 200
      }

      non_existing_hash_response = %HTTPoison.Response{
        body: "{\"jsonrpc\":\"2.0\",\"id\":1,\"result\":null}\n",
        headers: [
          {"Content-Type", "application/json"},
          {"Date", "Sun, 21 Aug 2022 13:10:58 GMT"},
          {"Content-Length", "39"}
        ],
        request: %HTTPoison.Request{
          body:
            "{\"params\":[\"0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b\"],\"method\":\"eth_getTransactionByHash\",\"jsonrpc\":\"2.0\",\"id\":1}",
          headers: [{"content-Type", "application/json"}],
          method: :post,
          options: [],
          params: %{},
          url: "http://localhost:8545"
        },
        request_url: "http://localhost:8545",
        status_code: 200
      }

      trans_response = %HTTPoison.Response{
        body:
          "{\"jsonrpc\":\"2.0\",\"id\":1,\"result\":{\"blockHash\":\"0x1d59ff54b1eb26b013ce3cb5fc9dab3705b415a67127a003c3e61eb445bb8df2\", \"blockNumber\":\"0x5daf3b\", 
         \"from\":\"0xa7d9ddbe1f17865597fbd27ec712455208b6b76d\",\"gas\":\"0xc350\",\"gasPrice\":\"0x4a817c800\",\"hash\":\"0x89de016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944c\",\"input\":\"0x68656c6c6f21\",
    \"nonce\":\"0x15\",\"to\":\"0xf02c1c8e6114b1dbe8937a39260b5b0a374432bb\",\"transactionIndex\":\"0x41\",\"value\":\"0xf3dbb76162000\",\"v\":\"0x25\",\"r\":\"0x1b5e176d927f8e9ab405058b2d2457392da3e20f328b16ddabcebc33eaac5fea\",\"s\":\"0x4ba69724e8f69de52f0125ad8b3c5c2cef33019bac3249e2c0a2192766d1721c\"
  }}\n",
        headers: [
          {"Content-Type", "application/json"},
          {"Date", "Sun, 21 Aug 2022 13:10:58 GMT"},
          {"Content-Length", "39"}
        ],
        request: %HTTPoison.Request{
          body:
            "{\"params\":[\"0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b\"],\"method\":\"eth_getTransactionByHash\",\"jsonrpc\":\"2.0\",\"id\":1}",
          headers: [{"content-Type", "application/json"}],
          method: :post,
          options: [],
          params: %{},
          url: "http://localhost:8545"
        },
        request_url: "http://localhost:8545",
        status_code: 200
      }

      [
        invalid_arg_response: invalid_arg_response,
        non_existing_hash_response: non_existing_hash_response,
        trans_response: trans_response
      ]
    end

    test "Error message is displayed for invalid request", %{invalid_arg_response: response} do
      Mox.stub(TransChain.HttpClientMock, :post!, fn _params, _method ->
        response
      end)

      %{"error" => error} = Poison.decode!(response.body)

      assert capture_log(fn ->
               TransChain.transaction(%Ethereum{
                 params: ["xxx"],
                 method: "eth_getTransactionByHash"
               })
             end) =~ error["message"]
    end

    test "notifies transaction of the given hash is non-existence", %{
      non_existing_hash_response: response
    } do
      Mox.stub(TransChain.HttpClientMock, :post!, fn _params, _method ->
        response
      end)

      assert capture_io(fn ->
               TransChain.transaction(%Ethereum{
                 params: ["0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b"],
                 method: "eth_getTransactionByHash"
               })
             end) =~ "No matching transaction"
    end

    test "returns full transaction info of the given hash", %{trans_response: response} do
      %{"result" => result} =
        response.body
        |> Poison.decode!()

      Mox.stub(TransChain.HttpClientMock, :post!, fn _params, _method ->
        response
      end)

      get_transaction =
        TransChain.transaction(%Ethereum{
          params: ["0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b"],
          method: "eth_getTransactionByHash"
        })

      assert get_transaction == :ok

      assert result["blockHash"] ==
               "0x1d59ff54b1eb26b013ce3cb5fc9dab3705b415a67127a003c3e61eb445bb8df2"

      assert result["to"] == "0xf02c1c8e6114b1dbe8937a39260b5b0a374432bb"

      assert result["gas"] == "0xc350"
    end
  end

  describe "send transaction" do
    setup do
      complete_trans_response = %HTTPoison.Response{
        body:
          "{\"jsonrpc\": \"2.0\",\"id\": 2,\"result\": {\"raw\": \"0xf88380018203339407a565b7ed7d7a678680a4c162885bedbb695fe080a44401a6e4000000000000000000000000000000000000000000000000000000000000001226a0223a7c9bcf5531c99be5ea7082183816eb20cfe0bbc322e97cc5c7f71ab8b20ea02aadee6b34b45bb15bc42d9c09de4a6754e7000908da72d48cc7704971491663\",
  \"tx\": {\"nonce\": \"0x0\",\"maxFeePerGas\": \"0x1234\",\"maxPriorityFeePerGas\": \"0x1234\",\"gas\": \"0x55555\",\"to\": \"0x07a565b7ed7d7a678680a4c162885bedbb695fe0\",\"value\": \"0x1234\",\"input\": \"0xabcd\",
  \"v\": \"0x26\",\"r\": \"0x223a7c9bcf5531c99be5ea7082183816eb20cfe0bbc322e97cc5c7f71ab8b20e\",
  \"s\": \"0x2aadee6b34b45bb15bc42d9c09de4a6754e7000908da72d48cc7704971491663\",\"hash\": \"0xeba2df809e7a612a0a0d444ccfa5c839624bdc00dd29e3340d46df3870f8a30e\"}}}\n",
        headers: [
          {"Content-Type", "application/json"},
          {"Date", "Sun, 21 Aug 2022 10:50:14 GMT"},
          {"Content-Length", "103"}
        ],
        request: %HTTPoison.Request{
          body:
            "{\"params\":[{\"value\":\"0x9184e72a\",\"to\":\"0xe27cD333167C923138B7312d946FF249d70fEB2a\",\"gasPrice\":\"0x9184e72a000\",\"gas\":\"0x76c0\",\"from\":\"0x85a8c4ac888f85a90Ee234ea820A8184a3b14a59\",\"data\":\"0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f072445675\"}],\"method\":\"eth_sendTransaction\",\"jsonrpc\":\"2.0\",\"id\":1}",
          headers: [{"content-Type", "application/json"}],
          method: :post,
          options: [],
          params: %{},
          url: "http://localhost:8545"
        },
        request_url: "http://localhost:8545",
        status_code: 200
      }

      failed_trans_response = %HTTPoison.Response{
        body:
          "{\"jsonrpc\":\"2.0\",\"id\":1,\"error\":{\"code\":-32000,\"message\":\"authentication needed: password or unlock\"}}\n",
        headers: [
          {"Content-Type", "application/json"},
          {"Date", "Mon, 15 Aug 2022 10:06:20 GMT"},
          {"Content-Length", "103"}
        ],
        request: %HTTPoison.Request{
          body:
            "{\"params\":[{\"value\":\"0x9184e72a\",\"to\":\"0xe27cD333167C923138B7312d946FF249d70fEB2a\",\"gasPrice\":\"0x9184e72a000\",\"gas\":\"0x76c0\",\"from\":\"0x85a8c4ac888f85a90Ee234ea820A8184a3b14a59\",\"data\":\"0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f072445675\"}],\"method\":\"eth_sendTransaction\",\"jsonrpc\":\"2.0\",\"id\":1}",
          headers: [{"content-Type", "application/json"}],
          method: :post,
          options: [],
          params: %{},
          url: "http://localhost:8545"
        },
        request_url: "http://localhost:8545",
        status_code: 200
      }

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

      [
        failed_trans_response: failed_trans_response,
        complete_trans_response: complete_trans_response,
        params: params
      ]
    end

    test "transaction is issued successfully", %{
      complete_trans_response: response,
      params: params
    } do
      Mox.stub(TransChain.HttpClientMock, :post!, fn _params, _method ->
        response
      end)

      %{"result" => result} = Poison.decode!(response.body)

      capture_io(fn ->
        TransChain.transaction(%Ethereum{
          params: params,
          method: "eth_sendTransaction"
        })
      end) =~ "Transaction completed successfully"

      capture_io(fn ->
        TransChain.transaction(%Ethereum{
          params: params,
          method: "eth_sendTransaction"
        })
      end) =~ "Transaction hash:#{result["hash"]}"

      capture_io(fn ->
        TransChain.transaction(%Ethereum{
          params: params,
          method: "eth_sendTransaction"
        })
      end) =~ "Transaction gas:#{result["gas"]}"
    end

    test "notifies on failed transaction", %{failed_trans_response: response, params: params} do
      Mox.stub(TransChain.HttpClientMock, :post!, fn _params, _method ->
        response
      end)

      capture_log(fn ->
        TransChain.transaction(%Ethereum{
          params: params,
          method: "eth_sendTransaction"
        })
      end) =~ "authentication needed: password or unlock"
    end
  end
end
