defmodule StoneAccountApiWeb.WithdrawRegisterControllerTest do
  use StoneAccountApiWeb.ConnCase
  describe "index" do
    test "lists all withdraw_registers", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization",  "Basic #{Base.encode64("admin:1234")}")
        |> get(Routes.withdraw_register_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end
end
