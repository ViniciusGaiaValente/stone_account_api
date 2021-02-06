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

  alias StoneAccountApi.Repo
  alias StoneAccountApi.Banking
  alias StoneAccountApi.Banking.Account
  alias StoneAccountApi.Withdraw

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
    |> check_balance()
    |> transfer_money()
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

  def validate_rules(
    %Withdraw{
      valid: valid,
      logged_account_number: logged_account,
      origin_account_number: origin_account,
      errors: errors
    } = withdraw
  ) do
    if valid && logged_account != origin_account &&
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

  defp fetch_account(
    %Withdraw{
    origin_account_number: origin_account_number,
    valid: valid} = withdraw
  ) do
    if valid do
      %Withdraw{
        withdraw |
        origin_account: Banking.get_account_by_number(origin_account_number)
      }
    else
      withdraw
    end
  end

  def check_account_existence(
    %Withdraw{
      origin_account: origin_account,
      errors: errors,
      valid: valid
    } = withdraw
  ) do
    if valid && origin_account == nil &&
    not Enum.member?(errors, "Could not found your account, please try to signin again.") do
      %Withdraw{
        withdraw |
        valid: false,
        status_code: :forbidden,
        errors: List.insert_at(errors, 0, "Could not found your account, please try to signin again.")
      }
    else
      withdraw
    end
  end

  def check_balance(
    %Withdraw{
      origin_account: origin_account,
      value: value,
      valid: valid,
      errors: errors
    } = withdraw
  ) do
    if valid do
      if Money.negative?(Money.subtract(origin_account.balance, value)) do
        %Withdraw{
          withdraw |
          valid: false,
          status_code: :unprocessable_entity,
          errors: List.insert_at(errors, 0, "Insufficient funds.")
        }
      else
        withdraw
      end
    else
      withdraw
    end
  end

  defp transfer_money(
    %Withdraw{
      origin_account: origin_account,
      value: value,
      valid: valid
    } = withdraw
  ) do
    if valid do
      %Withdraw{
        withdraw |
        origin_account_new_balance: origin_account
          |> Account.balance_update_changeset(%{ balance: Money.subtract(origin_account.balance, value) })
          |> Repo.update!()
          |> Map.fetch!(:balance)
      }
      else
        withdraw
      end
  end

  defp backoffice_entry(
    %Withdraw{
      # origin_account_number: origin_account_number,
      # destination_account_number: destination_account_number,
      # errors: errors,
      # value: value,
      valid: valid
    } = withdraw
  ) do
    if valid do
      # TODO SAVE SUCESSFULL ENTRY AT THE BACKOFFICE DATABASE
    else
      # TODO SAVE FAILED ATEMPT AT THE BACKOFFICE DATABASE
    end
    withdraw
  end

  defp extract_output(
    %Withdraw{
      valid: valid,
      errors: errors,
      status_code: status_code,
      value: value,
      origin_account_number: origin_account_number,
      origin_account_new_balance: origin_account_new_balance
    }
  ) do
    if valid do
      { :ok,
        %{
          origin: origin_account_number,
          value: value,
          balance: origin_account_new_balance,
        },
        status_code
      }
    else
      { :error, errors, status_code }
    end
  end
end