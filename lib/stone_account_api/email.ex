defmodule StoneAccountApi.Email do
  import Bamboo.Email

  alias StoneAccountApi.Email.Mailer

  def welcome_email do
    send(
      to: { "Vinicius Valente", "viniciusvalente.dev@gmail.com" },
      subject: "NOVO TESTE",
      html_body: "<strong>NOVO TESTE</strong>",
      text_body: "NOVO TESTE"
    )
  end

  def notify_withdraw(
    name: name,
    email: email,
    account_number: account_number,
    value: value
  ) do
    plain = "Ola #{name}. Você sacou #{value} reais da sua conta de numero: #{account_number}"
    html =
      """
        <div>
          <h1> Ola #{name}, </h1>
          <p> Você sacou #{Money.to_string(Money.new(value))} reais da sua conta de numero: #{account_number} </p>
        </div>
      """
      send(
        to: { name, email },
        subject: "Conta Stone - Saque",
        html_body: html,
        text_body: plain
      )
  end

  defp send(
      to: to,
      subject: subject,
      html_body: html_body,
      text_body: text_body
  ) do
    try do
      new_email(
        to: to,
        from: { "Conta Stone", "viniciusgaiavalente@gmail.com" },
        subject: subject,
        html_body: html_body,
        text_body: text_body
      )
      |> Mailer.deliver_now()
    rescue
      e in _ -> IO.inspect(e)
    end
  end
end
