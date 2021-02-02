defmodule StoneAccountApi.BankingTest do
  use StoneAccountApi.DataCase

  alias StoneAccountApi.Banking

  describe "accounts" do
    alias StoneAccountApi.Banking.Account

    @valid_attrs %{
      "password" => "some password",
      "holder" =>  %{
        "birthdate" => "1996-10-01T13:00:00",
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

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Banking.create_account()

      account
    end

    test "get_account_by_id/1 returns the account with given id" do
      account = account_fixture()
      assert Banking.get_account_by_id(account.id) == account
    end

    test "get_account_by_id/1 returns nil when called with an invalid id" do
      assert Banking.get_account_by_id(Ecto.UUID.generate) == nil
    end

    test "get_account_by_number/1 returns the account with given number" do
      fixture = account_fixture()
      account = Banking.get_account_by_number(fixture.number)

      assert account.number == fixture.number
      assert account.balance.amount == fixture.balance.amount
      assert account.holder.birthdate == fixture.holder.birthdate
      assert account.holder.email == fixture.holder.email
      assert account.holder.name == fixture.holder.name
    end

    test "get_account_by_number/1 returns nil when called with an invalid number" do
      assert Banking.get_account_by_number(0) == nil
    end

    test "create_account/1 with valid data creates a account" do
      assert { :ok, %Account{} = account } = Banking.create_account(@valid_attrs)
      assert is_integer(account.number)
      assert account.balance.amount == 100000
      assert account.holder.birthdate == ~N[1996-10-01 13:00:00]
      assert account.holder.email == "email@email.com"
      assert account.holder.name == "John Doe"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert { :error, %Ecto.Changeset{} } = Banking.create_account(@invalid_attrs)
    end
  end
end
