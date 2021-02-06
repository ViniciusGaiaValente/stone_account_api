defmodule StoneAccountApi.WithdrawControllerTest do
  use StoneAccountApiWeb.ConnCase

  describe "withdraw" do

    alias StoneAccountApi.Banking
    alias StoneAccountApi.Auth.Guardian

    @account_attrs %{
      "password" => "some password",
      "holder" =>  %{
        "birthdate" => "1996-10-01T13:00:00",
        "email" => "email@email.com",
        "name" => "John Doe"
      }
    }
    @other_attrs %{
      "password" => "some password",
      "holder" =>  %{
        "birthdate" => "1996-10-01T13:00:00",
        "email" => "other_email@email.com",
        "name" => "John Doe"
      }
    }

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@account_attrs)
        |> Banking.create_account()

      {:ok, token} = Guardian.authenticate(account.number, "some password")

      %{ account: account, token: token }
    end

    def other_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@other_attrs)
        |> Banking.create_account()

      account
    end

    test "renders the correct response for a sucefull operation.", %{conn: conn} do
      %{ account: account, token: token } = account_fixture()

      request =
        conn
        |> put_req_header("authorization",  "Bearer #{token}")
        |> post(Routes.withdraw_path(conn, :withdraw), origin: account.number, value: 50000)

      response = json_response(request, 200)

      assert %{
          "result" => %{
            "balance" => %{
              "decimal" => "500.0",
              "display" => "R$500,00",
              "precise" => 50000
            },
            "value" => 50000,
            "origin" => _origin
          }
        } = response
    end

    test "renders the correct error for a unauthenticated request.", %{conn: conn} do
      %{ account: account } = account_fixture()

      request =
        conn
        |> post(Routes.withdraw_path(conn, :withdraw), origin: account.number, value: 50000)

      response = json_response(request, 401)

      assert %{
        "error" => error
      } = response

      assert error == "unauthenticated"
    end

    test "renders the correct error for a invalid entry.", %{conn: conn} do
      %{ token: token } = account_fixture()

      request =
        conn
        |> put_req_header("authorization",  "Bearer #{token}")
        |> post(Routes.withdraw_path(conn, :withdraw), origin: "invalid origin", value: "invalid value")

      response = json_response(request, 400)

      assert %{
        "errors" => errors
      } = response

      assert Enum.member?(errors , "the 'origin' field must be a positive integer.")
      assert Enum.member?(errors , "the 'value' field must be a positive integer, it represents the amount to be transferred in cents.")
    end

    test "renders the correct error for a forbidden operation.", %{conn: conn} do
      %{ token: token } = account_fixture()
      other_account = other_fixture()

      request =
        conn
        |> put_req_header("authorization",  "Bearer #{token}")
        |> post(Routes.withdraw_path(conn, :withdraw), origin: other_account.number, value: 50000)

      response = json_response(request, 403)

      assert %{
        "errors" => errors
      } = response

      assert Enum.member?(errors , "You are not allowed to perform this operation.")
    end

    test "renders the correct error for account with insufficient funds.", %{conn: conn} do
      %{ account: account, token: token } = account_fixture()

      request =
        conn
        |> put_req_header("authorization",  "Bearer #{token}")
        |> post(Routes.withdraw_path(conn, :withdraw), origin: account.number, value: 150000)

      response = json_response(request, 422)

      assert %{
        "errors" => errors
      } = response

      assert Enum.member?(errors , "Insufficient funds.")
    end

  end
end
