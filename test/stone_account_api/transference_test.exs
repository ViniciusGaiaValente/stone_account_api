defmodule StoneAccountApi.TransferenceTest do
  use StoneAccountApi.DataCase

  describe "transference" do

    alias StoneAccountApi.Banking
    alias StoneAccountApi.Transference
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

    test "trasfer/3 valid entry performs correctly" do
      %{ account: sender } = sender_fixture()
      receiver = receiver_fixture()

      {
        :ok,
        %{
          value: value,
          origin: origin,
          destination: destination,
          balance: new_balance
        },
        _status
      } = Transference.tranfer(sender.number, sender.number, receiver.number, 50000)

      assert value == 50000
      assert origin == sender.number
      assert destination == receiver.number
      assert new_balance == Money.subtract(sender.balance, 50000)
    end

    test "trasfer/3 with invalid entry returns the correct error" do
      assert { :error, errors, _status } = Transference.tranfer("invalid logged_account", "invalid origin", "invalid destination", "invalid value")
      assert Enum.member?(errors , "the 'origin' field must be a positive integer.")
      assert Enum.member?(errors , "the 'destination' field must be a positive integer.")
      assert Enum.member?(errors , "the 'value' field must be a positive integer, it represents the amount to be transferred in cents.")
    end

    test "trasfer/3 with an invalid destination account returns the correct error" do
      %{ account: sender } = sender_fixture()

      assert { :error, errors, _status } = Transference.tranfer(sender.number, sender.number, 1, 50000)
      assert Enum.member?(errors , "This destination account does not exist.")
    end

    test "trasfer/3 with the same sender and destination account returns the correct error" do
      %{ account: sender } = sender_fixture()

      assert { :error, errors, _status } = Transference.tranfer(sender.number, sender.number, sender.number, 50000)
      assert Enum.member?(errors , "'origin' and 'destination' must be diferent.")
    end

    test "trasfer/3 only the logged holder can transfer money from it account" do
      %{ account: sender } = sender_fixture()
      receiver = receiver_fixture()

      assert { :error, errors, _status } = Transference.tranfer(receiver.number, sender.number, receiver.number, 50000)
      assert Enum.member?(errors , "You are not allowed to perform this operation.")
    end

    test "trasfer/3 with a bigger value than the sender balance returns the correct error" do
      %{ account: sender } = sender_fixture()
      receiver = receiver_fixture()

      assert { :error, errors, _status } = Transference.tranfer(sender.number, sender.number, receiver.number, 150000)
      assert Enum.member?(errors , "Insufficient funds.")
    end

  end
end
