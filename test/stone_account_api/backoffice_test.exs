defmodule StoneAccountApi.BackofficeTest do
  use StoneAccountApi.DataCase

  alias StoneAccountApi.Backoffice
  alias StoneAccountApi.Banking

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

    account
  end

  def other_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(@other_attrs)
      |> Banking.create_account()

    account
  end

  describe "withdraw_registers" do
    alias StoneAccountApi.Backoffice.WithdrawRegister

    @valid_attrs %{new_balance: Money.new(50000), old_balance: Money.new(100000), value: Money.new(50000)}
    @invalid_attrs %{new_balance: nil, old_balance: nil, value: nil, account_id: nil}

    def withdraw_register_fixture(attrs \\ %{}) do
      account = account_fixture()
      {:ok, withdraw_register} =
        attrs
        |> Enum.into(Map.put(@valid_attrs, :account_id, account.id))
        |> Backoffice.create_withdraw_register()

      withdraw_register
    end

    test "list_withdraw_registers/0 returns all withdraw_registers" do
      withdraw_register = withdraw_register_fixture()
      assert Backoffice.list_withdraw_registers() == [withdraw_register]
    end

    test "create_withdraw_register/1 with valid data creates a withdraw_register" do
      account = account_fixture()

      assert {:ok, %WithdrawRegister{} = withdraw_register} =
        Backoffice.create_withdraw_register(Map.put(@valid_attrs, :account_id, account.id))
      assert withdraw_register.new_balance == %Money{amount: 50000, currency: :BRL}
      assert withdraw_register.old_balance == %Money{amount: 100000, currency: :BRL}
      assert withdraw_register.value == %Money{amount: 50000, currency: :BRL}
    end

    test "create_withdraw_register/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Backoffice.create_withdraw_register(@invalid_attrs)
    end
  end

  describe "transference_registers" do
    alias StoneAccountApi.Backoffice.TransferenceRegister

    @valid_attrs %{destination_new_balance: Money.new(150000), destination_old_balance: Money.new(100000), origin_new_balance: Money.new(50000), origin_old_balance: Money.new(100000), value: Money.new(50000)}
    @invalid_attrs %{destination_new_balance: nil, destination_old_balance: nil, origin_new_balance: nil, origin_old_balance: nil, value: nil}

    def transference_register_fixture(attrs \\ %{}) do
      origin = account_fixture()
      destination = other_fixture()

      {:ok, transference_register} =
        attrs
        |> Enum.into(
          @valid_attrs
          |> Map.put(:origin_id, origin.id)
          |> Map.put(:destination_id, destination.id)
        )
        |> Backoffice.create_transference_register()

      transference_register
    end

    test "list_transference_registers/0 returns all transference_registers" do
      transference_register = transference_register_fixture()
      assert Backoffice.list_transference_registers() == [transference_register]
    end

    test "create_transference_register/1 with valid data creates a transference_register" do
      origin = account_fixture()
      destination = other_fixture()

      assert {:ok, %TransferenceRegister{} = transference_register} =
        Backoffice.create_transference_register(
          @valid_attrs
          |> Map.put(:origin_id, origin.id)
          |> Map.put(:destination_id, destination.id)
        )
      assert transference_register.destination_new_balance == %Money{amount: 150000, currency: :BRL}
      assert transference_register.destination_old_balance == %Money{amount: 100000, currency: :BRL}
      assert transference_register.origin_new_balance == %Money{amount: 50000, currency: :BRL}
      assert transference_register.origin_old_balance == %Money{amount: 100000, currency: :BRL}
      assert transference_register.value == %Money{amount: 50000, currency: :BRL}
    end

    test "create_transference_register/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Backoffice.create_transference_register(@invalid_attrs)
    end
  end
end
