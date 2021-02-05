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

  alias StoneAccountApi.Repo
  alias StoneAccountApi.Banking
  alias StoneAccountApi.Banking.Account
  alias StoneAccountApi.Transference

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
    |> check_balance()
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

  defp validate_rules(
    %Transference{
      valid: valid,
      logged_account_number: logged_account_number,
      origin_account_number: origin_account_number,
      destination_account_number: destination_account_number,
      errors: errors
    } = transference
  ) do
    cond do

      not valid -> transference

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

  defp fetch_accounts(
    %Transference{
    origin_account_number: origin_account_number,
    destination_account_number: destination_account_number,
    valid: valid} = transference
  ) do
    if valid do
      origin_account = Banking.get_account_by_number(origin_account_number)
      destination_account = Banking.get_account_by_number(destination_account_number)

      %Transference{
        transference |
        origin_account: origin_account,
        destination_account: destination_account
      }
    else
      transference
    end
  end

  defp check_accounts_existence(
    %Transference{
      origin_account: origin_account,
      destination_account: destination_account,
      errors: errors,
      valid: valid} = transference
  ) do

    cond do

      not valid -> transference

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

  defp check_balance(
    %Transference{
      origin_account: origin_account,
      value: value,
      valid: valid,
      errors: errors
    } = transference
  ) do
    if valid do
      if Money.negative?(Money.subtract(origin_account.balance, value)) do
        %Transference{
          transference |
          valid: false,
          status_code: :unprocessable_entity,
          errors: List.insert_at(errors, 0, "Insufficient funds.")
        }
      else
        transference
      end
    else
      transference
    end
  end

  defp transfer_money(
    %Transference{
      origin_account: origin_account,
      destination_account: destination_account,
      value: value,
      valid: valid
    } = transference
  ) do
    if valid do
      %Transference{
        transference |
        origin_account_new_balance: origin_account
          |> Account.balance_update_changeset(%{ balance: Money.subtract(origin_account.balance, value) })
          |> Repo.update!()
          |> Map.fetch!(:balance),
        destination_account_new_balance: destination_account
          |> Account.balance_update_changeset(%{ balance: Money.add(destination_account.balance, value) })
          |> Repo.update!()
          |> Map.fetch!(:balance)
      }
      else
        transference
      end
  end

  defp backoffice_entry(
    %Transference{
      # origin_account_number: origin_account_number,
      # destination_account_number: destination_account_number,
      # errors: errors,
      # value: value,
      valid: valid
    } = transference
  ) do
    if valid do
      # TODO SAVE SUCESSFULL ENTRY AT THE BACKOFFICE DATABASE
    else
      # TODO SAVE FAILED ATEMPT AT THE BACKOFFICE DATABASE
    end
    transference
  end

  defp extract_output(
    %Transference{
      valid: valid,
      errors: errors,
      status_code: status_code,
      value: value,
      origin_account_number: origin_account_number,
      destination_account_number: destination_account_number,
      origin_account_new_balance: origin_account_new_balance
    }
  ) do
    if valid do
      { :ok,
        %{
          origin: origin_account_number,
          destination: destination_account_number,
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
