defmodule StoneAccountApi.ReportControllerTest do
  use StoneAccountApiWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "report" do

    alias StoneAccountApi.Banking
    alias StoneAccountApi.Backoffice

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
    @withdraw_attrs %{new_balance: Money.new(95000), old_balance: Money.new(100000), value: Money.new(5000)}
    @transference_attrs %{destination_new_balance: Money.new(105000), destination_old_balance: Money.new(100000), origin_new_balance: Money.new(95000), origin_old_balance: Money.new(100000), value: Money.new(5000)}

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@account_attrs)
        |> Banking.create_account()

      account
    end

    def other_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@other_attrs)
        |> Banking.create_account()

      account
    end

    def transference_register_specific_accounts_fixture(origin, destination) do
      {:ok, transference_register} =
        %{}
        |> Enum.into(
          @transference_attrs
          |> Map.put(:origin_id, origin.id)
          |> Map.put(:destination_id, destination.id)
        )
        |> Backoffice.create_transference_register()

      transference_register
    end

    def withdraw_register_specific_account_fixture(account) do
      {:ok, withdraw_register} =
        %{}
        |> Enum.into(Map.put(@withdraw_attrs, :account_id, account.id))
        |> Backoffice.create_withdraw_register()

      withdraw_register
    end

    def report_ficture() do
      origin = account_fixture()
      destination = other_fixture()
      transference_register_specific_accounts_fixture(origin, destination)
      transference_register_specific_accounts_fixture(origin, destination)
      withdraw_register_specific_account_fixture(origin)
      withdraw_register_specific_account_fixture(origin)
    end

    test "day renders the correct data", %{conn: conn} do
      report_ficture()
      request = get(conn, Routes.report_path(conn, :day))
      assert json_response(request, 200)["total_transactions"] == "R$200,00"
    end

    test "month renders the correct data", %{conn: conn} do
      report_ficture()
      request = get(conn, Routes.report_path(conn, :month))
      assert json_response(request, 200)["total_transactions"] == "R$200,00"
    end

    test "year renders the correct data", %{conn: conn} do
      report_ficture()
      request = get(conn, Routes.report_path(conn, :year))
      assert json_response(request, 200)["total_transactions"] == "R$200,00"
    end
  end
end
