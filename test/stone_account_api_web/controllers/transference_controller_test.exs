defmodule StoneAccountApi.TransferenceControllerTest do
  use StoneAccountApiWeb.ConnCase

  describe "transfer" do

    alias StoneAccountApi.Banking
    alias StoneAccountApi.Auth.Guardian

    @sender_attrs %{
      "password" => "some password",
      "holder" =>  %{
        "birthdate" => "1996-10-01T13:00:00",
        "email" => "email@email.com",
        "name" => "John Doe"
      }
    }
    @receiver_attrs %{
      "password" => "some password",
      "holder" =>  %{
        "birthdate" => "1996-10-01T13:00:00",
        "email" => "other_email@email.com",
        "name" => "John Doe"
      }
    }

    setup %{conn: conn} do
      {:ok, conn: put_req_header(conn, "accept", "application/json")}
    end

    def sender_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@sender_attrs)
        |> Banking.create_account()

      {:ok, token} = Guardian.authenticate(account.number, "some password")

      %{ account: account, token: token }
    end

    def receiver_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@receiver_attrs)
        |> Banking.create_account()

      account
    end

    test "renders the correct response for a sucefull operation.", %{conn: conn} do
      %{ account: sender, token: token } = sender_fixture()
      receiver = receiver_fixture()

      request =
        conn
        |> put_req_header("authorization",  "Bearer #{token}")
        |> post(Routes.transference_path(conn, :transfer), origin: sender.number, destination: receiver.number, value: 50000)

      response = json_response(request, 200)

      assert %{
          "result" => %{
            "balance" => %{
              "decimal" => "500.0",
              "display" => "R$500,00",
              "precise" => 50000
            },
            "value" => 50000,
            "destination" => _destination,
            "origin" => _origin
          }
        } = response
    end

    test "renders the correct error for a unauthenticated request.", %{conn: conn} do
      %{ account: sender } = sender_fixture()
      receiver = receiver_fixture()

      request =
        conn
        |> post(Routes.transference_path(conn, :transfer), origin: sender.number, destination: receiver.number, value: 50000)

      response = json_response(request, 401)

      assert %{
        "error" => error
      } = response

      assert error == "unauthenticated"
    end

    test "renders the correct error for a invalid entry.", %{conn: conn} do
      %{ token: token } = sender_fixture()

      request =
        conn
        |> put_req_header("authorization",  "Bearer #{token}")
        |> post(Routes.transference_path(conn, :transfer), origin: "invalid origin", destination: "invalid destination", value: "invalid value")

      response = json_response(request, 400)

      assert %{
        "errors" => errors
      } = response

      assert Enum.member?(errors , "the 'origin' field must be a positive integer.")
      assert Enum.member?(errors , "the 'destination' field must be a positive integer.")
      assert Enum.member?(errors , "the 'value' field must be a positive integer, it represents the amount to be transferred in cents.")
    end

    test "renders the correct error for an nonexistent destination account.", %{conn: conn} do
      %{  account: sender, token: token } = sender_fixture()

      request =
        conn
        |> put_req_header("authorization",  "Bearer #{token}")
        |> post(Routes.transference_path(conn, :transfer), origin: sender.number, destination: 1, value: 500)

      response = json_response(request, 422)

      assert %{
        "errors" => errors
      } = response

      assert Enum.member?(errors , "This destination account does not exist.")
    end

    test "renders the correct error for a forbidden operation.", %{conn: conn} do
      %{ account: sender, token: token } = sender_fixture()
      receiver = receiver_fixture()

      request =
        conn
        |> put_req_header("authorization",  "Bearer #{token}")
        |> post(Routes.transference_path(conn, :transfer), origin: receiver.number, destination: sender.number, value: 50000)

      response = json_response(request, 403)

      assert %{
        "errors" => errors
      } = response

      assert Enum.member?(errors , "You are not allowed to perform this operation.")
    end

    test "renders the correct error for account with insufficient funds.", %{conn: conn} do
      %{ account: sender, token: token } = sender_fixture()
      receiver = receiver_fixture()

      request =
        conn
        |> put_req_header("authorization",  "Bearer #{token}")
        |> post(Routes.transference_path(conn, :transfer), origin: sender.number, destination: receiver.number, value: 150000)

      response = json_response(request, 422)

      assert %{
        "errors" => errors
      } = response

      assert Enum.member?(errors , "Insufficient funds.")
    end

    test "renders the correct error for request with the same sender and destination account.", %{conn: conn} do
      %{ account: sender, token: token } = sender_fixture()

      request =
        conn
        |> put_req_header("authorization",  "Bearer #{token}")
        |> post(Routes.transference_path(conn, :transfer), origin: sender.number, destination: sender.number, value: 150000)

      response = json_response(request, 422)

      assert %{
        "errors" => errors
      } = response

      assert Enum.member?(errors , "'origin' and 'destination' must be diferent.")
    end

  end
end
