defmodule StoneAccountApiWeb.AccountControllerTest do
  use StoneAccountApiWeb.ConnCase
  alias StoneAccountApi.Banking

  @create_attrs %{
    "password" => "some password",
    "holder" =>  %{
      "birthdate" => "1996-10-01T13:00:00",
      "email" => "email@email.com",
      "name" => "John Doe"
    }
  }
  @second_attrs %{
    "password" => "some password",
    "holder" =>  %{
      "birthdate" => "1996-10-01T13:00:00",
      "email" => "other_email@email.com",
      "name" => "John Doe"
    }
  }
  @invalid_attrs %{
    "password" => nil,
    "holder" =>  %{
      "birthdate" => nil,
      "email" => nil,
      "name" => nil
    }
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create account" do

    test "renders the correct account with valid data.", %{conn: conn} do
      create_request = post(conn, Routes.account_path(conn, :create), account: @create_attrs)
      account = json_response(create_request, 201)

      assert %{
        "account" => %{
          "balance" => %{
            "decimal" => "1000",
            "display" => "R$1.000,00",
            "precise" => 100000
          },
          "holder" => %{
            "birthdate" => "1996-10-01T13:00:00",
            "email" => "email@email.com"
          },
          "number" => number
        },
        "token" => token
      } = account

      assert is_integer(number)
      assert is_binary(token)
    end

    test "renders errors when data is invalid.", %{conn: conn} do
      create_request = post(conn, Routes.account_path(conn, :create), account: @invalid_attrs)
      assert json_response(create_request, 422)["errors"] != %{}
    end

    test "renders error for duplicated email.", %{conn: conn} do
      post(conn, Routes.account_path(conn, :create), account: @create_attrs)

      duplicated_create_request = post(conn, Routes.account_path(conn, :create), account: @create_attrs)
      assert json_response(duplicated_create_request, 422)["errors"] != %{}
    end

  end

  describe "signin" do

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@create_attrs)
        |> Banking.create_account()

      Banking.get_account_by_number(account.number)
    end

    test "renders a token when receives a valid number account and the right password.", %{conn: conn} do
      account = account_fixture()

      signin_request =
        conn
        |> put_req_header("authorization",  "Basic #{Base.encode64("#{account.number}:some password")}")
        |> get(Routes.account_path(conn, :signin))

      assert json_response(signin_request, 200)["token"] != nil
    end

    test "renders the correct error when receives a valid number account a wrong password.", %{conn: conn} do
      account = account_fixture()

      signin_request =
        conn
        |> put_req_header("authorization",  "Basic #{Base.encode64("#{account.number}:wrong password")}")
        |> get(Routes.account_path(conn, :signin))

      assert json_response(signin_request, 401)["error"] == "Wrong password"
    end

    test "renders the correct error when receives a invalid valid number account.", %{conn: conn} do
      signin_request =
        conn
        |> put_req_header("authorization",  "Basic #{Base.encode64("#{0}:any password")}")
        |> get(Routes.account_path(conn, :signin))

      assert json_response(signin_request, 401)["error"] == "Account not found"
    end

    test "renders the correct error when doesn't send an authorization header.", %{conn: conn} do
      signin_request =
        conn
        |> get(Routes.account_path(conn, :signin))

      assert json_response(signin_request, 400)["error"] == "In order to signin you need to provide a valid account number and password"
    end

  end

  describe "show account" do

    def account_and_token_fixture(%{conn: conn}) do
      create_request = post(conn, Routes.account_path(conn, :create), account: @create_attrs)
      json_response(create_request, 201)
    end

    def second_account_number_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@second_attrs)
        |> Banking.create_account()

        account.number
    end

    test "renders the correct account if the logged account matches the required account.", %{conn: conn} do
      %{ "account" => account, "token" => token } = account_and_token_fixture(%{conn: conn})
      show_request =
        conn
        |> put_req_header("authorization",  "Bearer #{token}")
        |> get(Routes.account_path(conn, :show, account["number"]))

      assert account == json_response(show_request, 200)
    end

    test "renders the correct error when tries to access another one's account.", %{conn: conn} do
      %{ "token" => token } = account_and_token_fixture(%{conn: conn})
      number = second_account_number_fixture()

      show_request =
        conn
        |> put_req_header("authorization",  "Bearer #{token}")
        |> get(Routes.account_path(conn, :show, number))

      assert json_response(show_request, 401)["error"] == "Only the account holder can access this information"
    end

    test "renders the correct error when not send a token.", %{conn: conn} do
      %{ "account" => account } = account_and_token_fixture(%{conn: conn})
      show_request =
        conn
        |> get(Routes.account_path(conn, :show, account["number"]))

      assert json_response(show_request, 401)["error"] == "unauthenticated"
    end

    test "renders the correct error when send a invalid token.", %{conn: conn} do
      %{ "account" => account } = account_and_token_fixture(%{conn: conn})
      show_request =
        conn
        |> put_req_header("authorization",  "Bearer some_invalid_token")
        |> get(Routes.account_path(conn, :show, account["number"]))

      assert json_response(show_request, 401)["error"] == "invalid_token"
    end

  end
end
