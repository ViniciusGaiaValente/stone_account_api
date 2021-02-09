defmodule StoneAccountApiWeb.ReportController do
  use StoneAccountApiWeb, :controller

  alias StoneAccountApi.Backoffice

  def day(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{ total_transactions: Backoffice.todays_report() })
  end

  def month(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{ total_transactions: Backoffice.this_month_report() })
  end

  def year(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{ total_transactions: Backoffice.this_year_report() })
  end
end
