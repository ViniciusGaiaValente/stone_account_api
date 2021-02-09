defmodule StoneAccountApi.EmailTest do
  use StoneAccountApi.DataCase

  alias StoneAccountApi.Email

  describe "mailer" do

    test "test welcome_email/0" do
      Email.welcome_email()
    end
  end
end
