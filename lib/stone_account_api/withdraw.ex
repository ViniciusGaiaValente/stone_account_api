defmodule StoneAccountApi.Withdraw do
  @moduledoc """
  The Withdraw context.
  """

  defstruct(
    logged_account_number: nil,
    origin_account_number: nil,
    origin_account: nil,
    origin_account_new_balance: nil,
    value: nil,
    valid: true,
    status_code: :ok,
    errors: []
  )

  alias Ecto.Multi
  alias StoneAccountApi.Repo
  alias StoneAccountApi.Banking
  alias StoneAccountApi.Banking.Account
  alias StoneAccountApi.Withdraw
  alias StoneAccountApi.Backoffice
  alias StoneAccountApi.Email

  @doc """
  Withdraw money from an account if all the validation passes.
  The value field represents the amount to be transferred in cents.
  Return a list of errors in case of validation errors or rules violation.
  Possible errors:
    - numeric fields are different them positive integers.
    - user's not logged to the account.
    - the value to be transferred is bigger than the account's balance.
  If the operation is successful an entry to the backoffice is fired in the background.
  """
  def withdraw(logged_account, origin, value) do
    withdraw(
      %Withdraw{
        logged_account_number: logged_account,
        origin_account_number: origin,
        value: value
      }
    )
  end

  defp withdraw(withdraw) do
    withdraw
    |> validate_entry()
    |> validate_rules()
    |> fetch_account()
    |> check_account_existence()
    |> withdraw_money()
    |> notify_email()
    |> backoffice_entry()
    |> extract_output()
  end

  defp validate_entry(
    %Withdraw{
      origin_account_number: origin_account,
      value: value,
      errors: errors
    } = withdraw
  ) do
    cond do

      not (is_integer(origin_account) && origin_account > 0) &&
      not Enum.member?(errors, "the 'origin' field must be a positive integer.") ->

        validate_entry(
          %Withdraw{
            withdraw |
            valid: false,
            status_code: :bad_request,
            errors: List.insert_at(errors, 0, "the 'origin' field must be a positive integer.")
          }
        )

      not (is_integer(value) && value > 0) &&
      not Enum.member?(errors, "the 'value' field must be a positive integer, it represents the amount to be transferred in cents.") ->

        validate_entry(
          %Withdraw{
            withdraw |
            valid: false,
            status_code: :bad_request,
            errors: List.insert_at(errors, 0, "the 'value' field must be a positive integer, it represents the amount to be transferred in cents.")
          }
        )

      true -> withdraw
    end
  end

  defp validate_rules(%{valid: valid} = withdraw) when not valid do withdraw end
  defp validate_rules(
    %Withdraw{
      logged_account_number: logged_account,
      origin_account_number: origin_account,
      errors: errors
    } = withdraw
  ) do
    if logged_account != origin_account &&
    not Enum.member?(errors, "You are not allowed to perform this operation.") do
      %Withdraw{
        withdraw |
        valid: false,
        status_code: :forbidden,
        errors: List.insert_at(errors, 0, "You are not allowed to perform this operation.")
      }
    else
      withdraw
    end
  end

  defp fetch_account(%{valid: valid} = withdraw) when not valid do withdraw end
  defp fetch_account(
    %Withdraw{
      origin_account_number: origin_account_number,
    } = withdraw
  ) do
    %Withdraw{
      withdraw |
      origin_account: Banking.get_account_by_number(origin_account_number)
    }
  end

  defp check_account_existence(%{valid: valid} = withdraw) when not valid do withdraw end
  defp check_account_existence(%{origin_account: origin_account} = withdraw) when origin_account != nil do withdraw end
  defp check_account_existence(%{errors: errors} = withdraw) do
    %Withdraw{
      withdraw |
      valid: false,
      status_code: :forbidden,
      errors: List.insert_at(errors, 0, "Could not found your account, please try to signin again.")
    }
  end

  defp validate_balance(balance, value) do
    if Money.negative?(Money.subtract(balance, value)) do
      { :error, "Insufficient funds." }
    else
      { :ok, true }
    end
  end

  defp withdraw_money(%{valid: valid} = withdraw) when not valid do withdraw end
  defp withdraw_money(
    %Withdraw{
      origin_account_number: origin_account_number,
      value: value,
      errors: errors
    } = withdraw
  ) do
    case Multi.new()
      |> Multi.run(:origin_account, fn _repo, _changes -> Banking.search_account(origin_account_number) end)
      |> Multi.run(:validate_balance, fn _repo, %{ origin_account: %{ balance: balance } } -> validate_balance(balance, value) end)
      |> Multi.run(:origin_account_new_balance, fn _repo, %{ origin_account: %{ balance: balance } = origin_account } ->
        { :ok,
          origin_account
          |> Account.balance_update_changeset(%{ balance: Money.subtract(balance, value) })
          |> Repo.update!()
          |> Map.fetch!(:balance),
        }
      end)
      |> Repo.transaction()
    do
      { :ok,
        %{
          origin_account: origin_account,
          origin_account_new_balance: origin_account_new_balance,
        }
      } ->
        %Withdraw{
          withdraw |
          origin_account: origin_account,
          origin_account_new_balance: origin_account_new_balance
        }
      {:error, _at, reason, _value } ->
        %Withdraw{
          withdraw |
          valid: false,
          status_code: :bad_request,
          errors: List.insert_at(errors, 0, reason)
        }
    end
  end

  defp notify_email(%{valid: valid} = withdraw) when not valid do withdraw end
  defp notify_email(
    %Withdraw{
      origin_account: origin_account,
      origin_account_number: origin_account_number,
      value: value
    } = withdraw
  ) do
    Task.async(fn ->
      %{
        holder: %{
          name: name,
          email: email
        }
      } = origin_account
      Email.notify_withdraw(
        name: name,
        email: email,
        account_number: origin_account_number,
        value: value
      )
    end)

    withdraw
  end

  defp backoffice_entry(%{valid: valid} = withdraw) when not valid do withdraw end
  defp backoffice_entry(
    %Withdraw{
      origin_account: origin_account,
      origin_account_new_balance: origin_account_new_balance,
      value: value
    } = withdraw
  ) do
    Task.async(fn ->
      {result, reason} = Backoffice.create_withdraw_register(
        %{
          new_balance: origin_account_new_balance,
          old_balance: origin_account.balance,
          value: Money.new(value),
          account_id: origin_account.id
        }
      )

      if result == :error do
        IO.inspect(reason)
      end
    end)

    withdraw
  end

  defp extract_output(
    %Withdraw{
      valid: valid,
      errors: errors,
      status_code: status_code
    }
  ) when not valid do { :error, errors, status_code } end

  defp extract_output(
    %Withdraw{
      status_code: status_code,
      value: value,
      origin_account_number: origin_account_number,
      origin_account_new_balance: origin_account_new_balance
    }
  ) do
    { :ok,
      %{
        origin: origin_account_number,
        value: value,
        balance: origin_account_new_balance,
      },
      status_code
    }
  end
end
