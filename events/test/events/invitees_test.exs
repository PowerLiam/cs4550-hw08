defmodule Events.InviteesTest do
  use Events.DataCase

  alias Events.Invitees

  describe "invites" do
    alias Events.Invitees.Invitee

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def invitee_fixture(attrs \\ %{}) do
      {:ok, invitee} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Invitees.create_invitee()

      invitee
    end

    test "list_invites/0 returns all invites" do
      invitee = invitee_fixture()
      assert Invitees.list_invites() == [invitee]
    end

    test "get_invitee!/1 returns the invitee with given id" do
      invitee = invitee_fixture()
      assert Invitees.get_invitee!(invitee.id) == invitee
    end

    test "create_invitee/1 with valid data creates a invitee" do
      assert {:ok, %Invitee{} = invitee} = Invitees.create_invitee(@valid_attrs)
    end

    test "create_invitee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Invitees.create_invitee(@invalid_attrs)
    end

    test "update_invitee/2 with valid data updates the invitee" do
      invitee = invitee_fixture()
      assert {:ok, %Invitee{} = invitee} = Invitees.update_invitee(invitee, @update_attrs)
    end

    test "update_invitee/2 with invalid data returns error changeset" do
      invitee = invitee_fixture()
      assert {:error, %Ecto.Changeset{}} = Invitees.update_invitee(invitee, @invalid_attrs)
      assert invitee == Invitees.get_invitee!(invitee.id)
    end

    test "delete_invitee/1 deletes the invitee" do
      invitee = invitee_fixture()
      assert {:ok, %Invitee{}} = Invitees.delete_invitee(invitee)
      assert_raise Ecto.NoResultsError, fn -> Invitees.get_invitee!(invitee.id) end
    end

    test "change_invitee/1 returns a invitee changeset" do
      invitee = invitee_fixture()
      assert %Ecto.Changeset{} = Invitees.change_invitee(invitee)
    end
  end
end
