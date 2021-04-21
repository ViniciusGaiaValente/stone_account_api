defmodule StoneAccountApi.Transference do
  @moduledoc """
  The Transference context.
  """

  defstruct(
    logged_account_number: nil,
    origin_account_number: nil,
    origin_account: nil,
    origin_account_new_balance: nil,
    destination_account_number: nil,
    destination_account: nil,
    destination_account_new_balance: nil,
    value: nil,
    valid: true,
    status_code: :ok,
    errors: []
  )

  alias Ecto.Multi
  alias StoneAccountApi.Repo
  alias StoneAccountApi.Banking
  alias StoneAccountApi.Banking.Account
  alias StoneAccountApi.Transference
  alias StoneAccountApi.Backoffice

  @doc """
  Transfer money from an account to another if all the validation passes.
  The value field represents the amount to be transferred in cents.
  Return a list of errors in case of validation errors or rules violation.
  Possible errors:
    - numeric fields are different them positive integers.
    - the origin account and the destination account are the same.
    - user's not logged to the origin account.
    - the value to be transferred is bigger than the origin account's balance.
  If the operation is successful an entry to the backoffice is fired in the background.
  """
  def tranfer(logged_account, origin, destination, value) do
    tranfer(
        %Transference{
        logged_account_number: logged_account,
        origin_account_number: origin,
        destination_account_number: destination,
        value: value}
      )
  end

  defp tranfer(transference) do
    transference
    |> validate_entry()
    |> validate_rules()
    |> fetch_accounts()
    |> check_accounts_existence()
    |> transfer_money()
    |> backoffice_entry()
    |> extract_output()
  end

  defp validate_entry(
    %Transference{
      origin_account_number: origin_account_number,
      destination_account_number: destination_account_number,
      value: value,
      errors: errors
    } = transference
  ) do
    cond do

      not (is_integer(origin_account_number) && origin_account_number > 0) &&
      not Enum.member?(errors, "the 'origin' field must be a positive integer.") ->

        validate_entry(
          %Transference{
            transference |
            valid: false,
            status_code: :bad_request,
            errors: List.insert_at(errors, 0, "the 'origin' field must be a positive integer.")
          }
        )

      not (is_integer(destination_account_number) && destination_account_number > 0) &&
      not Enum.member?(errors, "the 'destination' field must be a positive integer.") ->

        validate_entry(
          %Transference{
            transference |
            valid: false,
            status_code: :bad_request,
            errors: List.insert_at(errors, 0, "the 'destination' field must be a positive integer.")
          }
        )

      not (is_integer(value) && value > 0) &&
      not Enum.member?(errors, "the 'value' field must be a positive integer, it represents the amount to be transferred in cents.") ->

        validate_entry(
          %Transference{
            transference |
            valid: false,
            status_code: :bad_request,
            errors: List.insert_at(errors, 0, "the 'value' field must be a positive integer, it represents the amount to be transferred in cents.")
          }
        )

      true -> transference
    end
  end

  defp validate_rules(%{valid: valid} = transference) when not valid do transference end
  defp validate_rules(
    %Transference{
      logged_account_number: logged_account_number,
      origin_account_number: origin_account_number,
      destination_account_number: destination_account_number,
      errors: errors
    } = transference
  ) do
    cond do

      origin_account_number == destination_account_number &&
      not Enum.member?(errors, "'origin' and 'destination' must be diferent.") ->

        validate_entry(
          %Transference{
            transference |
            valid: false,
            status_code: :unprocessable_entity,
            errors: List.insert_at(errors, 0, "'origin' and 'destination' must be diferent.")
          }
        )

      logged_account_number != origin_account_number &&
      not Enum.member?(errors, "You are not allowed to perform this operation.") ->

        validate_entry(
          %Transference{
            transference |
            valid: false,
            status_code: :forbidden,
            errors: List.insert_at(errors, 0, "You are not allowed to perform this operation.")
          }
        )

      true -> transference
    end
  end

  defp fetch_accounts(%{valid: valid} = transference) when not valid do transference end
  defp fetch_accounts(
    %Transference{
      origin_account_number: origin_account_number,
      destination_account_number: destination_account_number
    } = transference
  ) do
    origin_account = Banking.get_account_by_number(origin_account_number)
    destination_account = Banking.get_account_by_number(destination_account_number)

    %Transference{
      transference |
      origin_account: origin_account,
      destination_account: destination_account
    }
  end

  defp check_accounts_existence(%{valid: valid} = transference) when not valid do transference end
  defp check_accounts_existence(
    %Transference{
      origin_account: origin_account,
      destination_account: destination_account,
      errors: errors
    } = transference
  ) do
    cond do
      origin_account == nil &&
      not Enum.member?(
        errors,
        "Could not found your account, please try to signin again."
      ) ->
        check_accounts_existence(
          %Transference{
            transference |
            valid: false,
            status_code: :unprocessable_entity,
            errors: List.insert_at(errors, 0, "Could not found your account, please try to signin again.")
          })
      destination_account == nil &&
      not Enum.member?(
        errors,
        "This destination account does not exist."
      ) ->
        check_accounts_existence(
          %Transference{
            transference |
            valid: false,
            status_code: :unprocessable_entity,
            errors: List.insert_at(errors, 0, "This destination account does not exist.")
          })
      true -> transference
    end
  end

  defp validate_balance(balance, value) do
    if Money.negative?(Money.subtract(balance, value)) do
      { :error, "Insufficient funds." }
    else
      { :ok, true }
    end
  end

  defp transfer_money(%{valid: valid} = transference) when not valid do transference end
  defp transfer_money(
    %Transference{
      origin_account_number: origin_account_number,
      destination_account_number: destination_account_number,
      value: value,
      errors: errors
    } = transference
  ) do
    case Multi.new()
      |> Multi.run(:origin_account, fn _repo, _changes -> Banking.search_account(origin_account_number) end)
      |> Multi.run(:validate_balance, fn _repo, %{ origin_account: %{ balance: balance } } -> validate_balance(balance, value) end)
      |> Multi.run(:destination_account, fn _repo, _changes -> Banking.search_account(destination_account_number) end)
      |> Multi.run(:origin_account_new_balance, fn _repo, %{ origin_account: %{ balance: balance } = origin_account } ->
        { :ok,
          origin_account
          |> Account.balance_update_changeset(%{ balance: Money.subtract(balance, value) })
          |> Repo.update!()
          |> Map.fetch!(:balance),
        }
      end)
      |> Multi.run(:destination_account_new_balance, fn _repo, %{ destination_account: %{ balance: balance } = destination_account } ->
        { :ok,
        destination_account
        |> Account.balance_update_changeset(%{ balance: Money.add(balance, value) })
        |> Repo.update!()
        |> Map.fetch!(:balance)
        }
      end)
      |> Repo.transaction()
    do
      { :ok,
        %{
          origin_account: origin_account,
          destination_account: destination_account,
          origin_account_new_balance: origin_account_new_balance,
          destination_account_new_balance: destination_account_new_balance
        }
      } ->
        %Transference{
          transference |
          origin_account: origin_account,
          destination_account: destination_account,
          origin_account_new_balance: origin_account_new_balance,
          destination_account_new_balance: destination_account_new_balance
        }
      {:error, _at, reason, _value } ->
        %Transference{
          transference |
          valid: false,
          status_code: :bad_request,
          errors: List.insert_at(errors, 0, reason)
        }
    end
  end

  defp backoffice_entry(%{valid: valid} = transference) when not valid do transference end
  defp backoffice_entry(
    %Transference{
      origin_account: origin_account,
      origin_account_new_balance: origin_account_new_balance,
      destination_account: destination_account,
      destination_account_new_balance: destination_account_new_balance,
      value: value
    } = transference
  ) do
    Task.async(fn ->
      {result, reason} = Backoffice.create_transference_register(
        %{
          origin_old_balance: origin_account.balance,
          origin_new_balance: origin_account_new_balance,
          destination_old_balance: destination_account.balance,
          destination_new_balance: destination_account_new_balance,
          value: Money.new(value),
          origin_id: origin_account.id,
          destination_id: destination_account.id
        }
      )

      if result == :error do
        IO.inspect(reason)
      end
    end)

    transference
  end

  defp extract_output(
    %Transference{
      valid: valid,
      errors: errors,
      status_code: status_code
    }
  ) when not valid do { :error, errors, status_code } end

  defp extract_output(
    %Transference{
      status_code: status_code,
      value: value,
      origin_account_number: origin_account_number,
      destination_account_number: destination_account_number,
      origin_account_new_balance: origin_account_new_balance
    }
  ) do
    { :ok,
      %{
        origin: origin_account_number,
        destination: destination_account_number,
        value: value,
        balance: origin_account_new_balance,
      },
      status_code
    }
  end
end
