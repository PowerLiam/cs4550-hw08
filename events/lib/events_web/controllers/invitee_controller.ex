defmodule EventsWeb.InviteeController do
  use EventsWeb, :controller

  alias Events.Invitees
  alias Events.Invitees.Invitee

  alias EventsWeb.Plugs

  plug Plugs.RequireUser when action in [:new, :edit, :create, :update]
  plug :fetch_invitee when action in [:show, :edit, :update, :delete]
  plug :require_owner when action in [:edit, :update, :delete]

  def fetch_invitee(conn, _args) do
    id = conn.params["id"]
    invitee = Invitees.get_invitee!(id)
    assign(conn, :invitee, invitee)
  end

  def require_owner(conn, _args) do
    user = conn.assigns[:current_user]
    invitee = conn.assigns[:invitee]

    if user.id == invitee.source_user_id do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to modify that invite.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def index(conn, _params) do
    invites = Invitees.list_invites()
    render(conn, "index.html", invites: invites)
  end

  def new(conn, _params) do
    changeset = Invitees.change_invitee(%Invitee{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"invitee" => invitee_params}) do
    event_id = invitee_params["event_id"]
    event = Users.get_event!(event_id)

    user_id = invitee_params["user_id"]
    user = Admin.get_user!(user_id)

    invitees_for_event = Invitees.list_invitees_for_event(event)
    invitee_user_ids = Enum.map((invitee) -> invitee.user.id)

    current_user_id = conn.assigns[:current_user].id

    valid = 
      event && 
      user &&
      event.user.id == current_user_id &&
      !MapSet.member?(MapSet.new(invitee_user_ids), user_id) &&
      current_user_id != user_id

    if valid do
      case Invitees.create_invitee(invitee_params) do
        {:ok, invitee} ->
          conn
          |> put_flash(:info, "Invitee created successfully.")
          |> redirect(to: Routes.invitee_path(conn, :show, invitee))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else 
      {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    invitee = Invitees.get_invitee!(id)
    render(conn, "show.html", invitee: invitee)
  end

  def edit(conn, %{"id" => id}) do
    invitee = Invitees.get_invitee!(id)
    changeset = Invitees.change_invitee(invitee)
    render(conn, "edit.html", invitee: invitee, changeset: changeset)
  end

  def update(conn, %{"id" => id, "invitee" => invitee_params}) do
    invitee = Invitees.get_invitee!(id)

    case Invitees.update_invitee(invitee, invitee_params) do
      {:ok, invitee} ->
        conn
        |> put_flash(:info, "Invitee updated successfully.")
        |> redirect(to: Routes.invitee_path(conn, :show, invitee))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", invitee: invitee, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    invitee = Invitees.get_invitee!(id)
    {:ok, _invitee} = Invitees.delete_invitee(invitee)

    conn
    |> put_flash(:info, "Invitee deleted successfully.")
    |> redirect(to: Routes.invitee_path(conn, :index))
  end
end
