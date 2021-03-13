defmodule Events.Invitees do
  @moduledoc """
  The Invitees context.
  """

  import Ecto.Query, warn: false
  alias Events.Repo

  alias Events.Invitees.Invitee

  @doc """
  Returns the list of invites.

  ## Examples

      iex> list_invites()
      [%Invitee{}, ...]

  """
  def list_invites do
    Repo.all(Invitee) |> Repo.preload([:user, :event])
  end

  def list_invitees_for_event(event) do
    Repo.all(from(i in Invitee, where: i.event_id == ^event.id)) |> Repo.preload([:user, :event])
  end

  @doc """
  Gets a single invitee.

  Raises `Ecto.NoResultsError` if the Invitee does not exist.

  ## Examples

      iex> get_invitee!(123)
      %Invitee{}

      iex> get_invitee!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invitee!(id), do: Repo.get!(Invitee, id) |> Repo.preload([:user, :event])

  @doc """
  Creates a invitee.

  ## Examples

      iex> create_invitee(%{field: value})
      {:ok, %Invitee{}}

      iex> create_invitee(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invitee(attrs \\ %{}) do
    %Invitee{}
    |> Invitee.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invitee.

  ## Examples

      iex> update_invitee(invitee, %{field: new_value})
      {:ok, %Invitee{}}

      iex> update_invitee(invitee, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invitee(%Invitee{} = invitee, attrs) do
    invitee
    |> Invitee.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a invitee.

  ## Examples

      iex> delete_invitee(invitee)
      {:ok, %Invitee{}}

      iex> delete_invitee(invitee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invitee(%Invitee{} = invitee) do
    Repo.delete(invitee)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invitee changes.

  ## Examples

      iex> change_invitee(invitee)
      %Ecto.Changeset{data: %Invitee{}}

  """
  def change_invitee(%Invitee{} = invitee, attrs \\ %{}) do
    Invitee.changeset(invitee, attrs)
  end
end
