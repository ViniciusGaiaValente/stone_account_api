defmodule StoneAccountApiWeb.AccountControllerTest do
  use StoneAccountApiWeb.ConnCase

  @create_attrs %{
    "password" => "some password_hash",
    "holder" =>  %{
      "birthdate" => "1996-04-17T14:00:00",
      "email" => "email@email.com",
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

    test "sucessefuly with valid data", %{conn: conn} do
      create_request = post(conn, Routes.account_path(conn, :create), account: @create_attrs)
      account = json_response(create_request, 201)["data"]
      assert %{"id" => _id} = account
    end

    test "renders the right account for the given entry", %{conn: conn} do
      create_request = post(conn, Routes.account_path(conn, :create), account: @create_attrs)
      account = json_response(create_request, 201)["data"]

      assert is_binary(account["id"])
      assert is_integer(account["number"])
      assert account["balance"]["decimal"] == "1000"
      assert account["balance"]["display"] == "R$1.000,00"
      assert account["balance"]["precise"] == 100000
      assert account["holder"]["birthdate"] == "1996-04-17T14:00:00"
      assert account["holder"]["email"] == "email@email.com"
      assert account["holder"]["name"] == "John Doe"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      create_request = post(conn, Routes.account_path(conn, :create), account: @invalid_attrs)
      assert json_response(create_request, 422)["errors"] != %{}
    end

    test "renders error for duplicated email", %{conn: conn} do
      original_create_request = post(conn, Routes.account_path(conn, :create), account: @create_attrs)
      account = json_response(original_create_request, 201)["data"]
      assert %{"id" => _id} = account

      duplicated_create_request = post(conn, Routes.account_path(conn, :create), account: @create_attrs)
      assert json_response(duplicated_create_request, 422)["errors"] != %{}
    end

  end

  describe "show account" do

    test "renders the right account for the given id", %{conn: conn} do
      create_request = post(conn, Routes.account_path(conn, :create), account: @create_attrs)
      create_response = json_response(create_request, 201)["data"]
      assert %{"id" => create_id} = create_response

      show_request = get(conn, Routes.account_path(conn, :show, create_id))
      show_response = json_response(show_request, 200)["data"]
      assert %{"id" => _id} = show_response

      assert create_response == show_response
    end

  end
end
