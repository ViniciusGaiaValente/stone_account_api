defmodule StoneAccountApi.BankingTest do
  use StoneAccountApi.DataCase

  alias StoneAccountApi.Banking

  describe "accounts" do
    alias StoneAccountApi.Banking.Account

    @valid_attrs %{
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

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Banking.create_account()

      account
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Banking.get_account!(account.id)
        ==
        account
        |> Map.delete(:password)
        |> Map.delete(:password_hash)
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = Banking.create_account(@valid_attrs)
      assert is_integer(account.number)
      assert account.balance == 1000
      assert account.holder.birthdate == ~N[2014-04-17 14:00:00]
      assert account.holder.email == "email3@email.com"
      assert account.holder.name == "John Doe"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Banking.create_account(@invalid_attrs)
    end
  end
end
