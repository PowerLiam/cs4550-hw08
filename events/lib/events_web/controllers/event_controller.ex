defmodule EventsWeb.EventController do
  use EventsWeb, :controller

  alias Events.Users
  alias Events.Users.Event

  alias EventsWeb.Plugs

  plug Plugs.RequireUser when action in [:new, :edit, :create, :update]
  plug :fetch_event when action in [:show, :edit, :update, :delete]
  plug :require_owner when action in [:edit, :update, :delete]

  def fetch_event(conn, _args) do
    id = conn.params["id"]
    event = Users.get_event!(id)
    assign(conn, :event, event)
  end

  def require_owner(conn, _args) do
    user = conn.assigns[:current_user]
    event = conn.assigns[:event]

    if user.id == event.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to modify that event.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def index(conn, _params) do
    events = Users.list_events()
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Users.change_event(%Event{})
    try do
      render(conn, "new.html", changeset: changeset)
    rescue
      err in ArgumentError -> 
        IO.puts(Exception.format(:error, err, __STACKTRACE__))
        err
    end
  end

  def create(conn, %{"event" => event_params}) do
    post_params = post_params
    |> Map.put("user_id", conn.assigns[:current_user].id)

    case Users.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event = conn.assigns[:event]
    render(conn, "show.html", event: event)
  end

  def edit(conn, %{"id" => id}) do
    event = conn.assigns[:event]
    changeset = Users.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = conn.assigns[:event]

    case Users.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = conn.assigns[:event]
    {:ok, _event} = Users.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
