defmodule StoneAccountApi.Auth.Guardian do
  use Guardian, otp_app: :stone_account_api

  alias StoneAccountApi.Banking

  def subject_for_token(id, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    {:ok,  id}
  end

  def authenticate(number, password) do
    case Banking.get_account_by_number(number) do
      nil ->
        {:error, "Account not found"}
      account ->
        if validate_password(password, account.password_hash) do
          create_token(account)
        else
          {:error, "Wrong password"}
        end
    end
  end

  defp validate_password(password, password_hash) do
    Bcrypt.verify_pass(password, password_hash)
  end

  defp create_token(account) do
    {:ok, token, _claims} = encode_and_sign(account.id)
    {:ok, token}
  end
end
