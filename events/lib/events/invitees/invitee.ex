defmodule Events.Invitees.Invitee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invites" do
    field :event_id, :id
    field :user_id, :id
    field :source_user_id, :id

    timestamps()
  end

  @doc false
  def changeset(invitee, attrs) do
    invitee
    |> cast(attrs, [])
    |> validate_required([])
  end
end
