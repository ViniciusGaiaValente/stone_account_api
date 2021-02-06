defmodule StoneAccountApi.WithdrawTest do
  use StoneAccountApi.DataCase

  describe "withdraw" do

    alias StoneAccountApi.Banking
    alias StoneAccountApi.Withdraw

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

      %{ account: account }
    end

    def other_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@other_attrs)
        |> Banking.create_account()

      account
    end

    test "withdraw/3 with a valid entry performs correctly." do
      %{ account: account } = account_fixture()

      {
        :ok,
        %{
          value: value,
          origin: origin,
          balance: new_balance
        },
        _status
      } = Withdraw.withdraw(account.number, account.number, 50000)

      assert value == 50000
      assert origin == account.number
      assert new_balance == Money.subtract(account.balance, 50000)
    end

    test "withdraw/3 with a invalid entry returns the correct error." do
      assert { :error, errors, _status } = Withdraw.withdraw("invalid logged_account", "invalid origin", "invalid value")
      assert Enum.member?(errors , "the 'origin' field must be a positive integer.")
      assert Enum.member?(errors , "the 'value' field must be a positive integer, it represents the amount to be transferred in cents.")
    end

    test "withdraw/3 only the logged holder can withdraw money from it account" do
      %{ account: account } = account_fixture()
      other_account = other_fixture()

      assert { :error, errors, _status } = Withdraw.withdraw(other_account.number, account.number, 500)
      assert Enum.member?(errors , "You are not allowed to perform this operation.")
    end

    test "withdraw/3 with a bigger value than the account balance returns the correct error" do
      %{ account: account } = account_fixture()

      assert { :error, errors, _status } = Withdraw.withdraw(account.number, account.number, 150000)
      assert Enum.member?(errors , "Insufficient funds.")
    end

  end
end
