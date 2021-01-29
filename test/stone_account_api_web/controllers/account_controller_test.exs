defmodule StoneAccountApiWeb.AccountControllerTest do
  use StoneAccountApiWeb.ConnCase

  @create_attrs %{
    "password" => "some password_hash",
    "holder" =>  %{
      "birthdate" => "2014-04-17T14:00:00",
      "email" => "email3@email.com",
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

    test "renders account when data is valid", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.account_path(conn, :show, id))

      account = json_response(conn, 200)["data"]

      assert is_integer(account["number"])
      assert account["balance"] == 1000
      assert account["holder"]["birthdate"] == "2014-04-17T14:00:00"
      assert account["holder"]["email"] == "email3@email.com"
      assert account["holder"]["name"] == "John Doe"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), account: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

  end
end
