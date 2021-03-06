defmodule EventsWeb.InviteeController do
  use EventsWeb, :controller

  alias Events.Invitees
  alias Events.Invitees.Invitee
  alias Events.Users
  alias Events.Admin

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

    if user.id == invitee.user_id do
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
    try do
      invitee_params = invitee_params
        |> Map.put("user_id", current_user_id(conn))

      IO.inspect(invitee_params)

      event_id = invitee_params["event_id"]
      event = Users.get_event!(event_id)

      invited_user_name = invitee_params["invitee_name"]
      invited_user = Admin.get_user_by_name(invited_user_name)

      invitees_for_event = Invitees.list_invitees_for_event(event)
      invitee_user_ids = Enum.map(invitees_for_event, fn (invitee) -> invitee.user.id end)

      current_user_id = conn.assigns[:current_user].id

      valid = 
        event && 
        invited_user &&
        event.user_id == current_user_id &&
        !MapSet.member?(MapSet.new(invitee_user_ids), invited_user.id) &&
        current_user_id != invited_user.id

      if valid do
        invitee_params = invitee_params
          |> Map.put("invited_user_id", invited_user.id)

        case Invitees.create_invitee(invitee_params) do
          {:ok, invitee} ->
            conn
            |> put_flash(:info, "Invitee created successfully.")
            |> redirect(to: Routes.event_path(conn, :show, event))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
      else 
        case Invitees.create_invitee(%{}) do
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
      end
    rescue
      err ->
        IO.puts(Exception.format(:error, err, __STACKTRACE__))
        {:error, :processing_failed}
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
