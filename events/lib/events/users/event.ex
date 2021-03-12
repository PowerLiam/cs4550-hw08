defmodule Events.Users.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :date, :utc_datetime
    field :description, :string
    field :name, :string
    belongs_to :user, Events.Admin.User
    has_many :comments, Events.Comments.Comment

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :date, :description, :user_id])
    |> validate_required([:name, :date, :description, :user_id])
  end
end
