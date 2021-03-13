defmodule Events.Invitees.Invitee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invites" do
    belongs_to :event, Events.Users.Event
    belongs_to :user, Events.Admin.User
    has_one :user, Events.Admin.User

    timestamps()
  end

  @doc false
  def changeset(invitee, attrs) do
    invitee
    |> cast(attrs, [:event_id, :user_id, :source_user_id])
    |> validate_required([:event_id, :user_id, :source_user_id])
  end
end
