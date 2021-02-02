defmodule StoneAccountApi.AuthTest do
  use StoneAccountApi.DataCase

  alias StoneAccountApi.Auth.Guardian
  alias StoneAccountApi.Banking

    @create_attrs %{
      "password" => "some password",
      "holder" =>  %{
        "birthdate" => "1996-10-01T13:00:00",
        "email" => "email@email.com",
        "name" => "John Doe"
      }
    }

  describe "guardian" do

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@create_attrs)
        |> Banking.create_account()

      Banking.get_account_by_number(account.number)
    end

    test "authenticate/2 returns a token when the account number and password are correct." do
      %{ number: number } = account_fixture()
      assert {:ok, _token} = Guardian.authenticate(number, "some password")
    end

    test "authenticate/2 returns the correct error when the password is incorrect." do
      %{ number: number } = account_fixture()
      assert {:error, "Wrong password"} = Guardian.authenticate(number, "wrong password")
    end

    test "authenticate/2 returns the correct error when the account number is invalid." do
      assert {:error, "Account not found"} = Guardian.authenticate(0, "any password")
    end
  end
end
