defmodule StoneAccountApiWeb.TransferenceRegisterControllerTest do
  use StoneAccountApiWeb.ConnCase

  describe "index" do
    test "lists all transference_registers", %{conn: conn} do
      conn = get(conn, Routes.transference_register_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end
end
