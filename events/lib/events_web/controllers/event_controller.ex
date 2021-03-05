defmodule EventsWeb.EventController do
  use EventsWeb, :controller

  alias Events.Users
  alias Events.Users.Event

  alias EventsWeb.Plugs
  # plug Plugs.RequireUser when action not in [
  #  :index, :show, :photo] TODO
  plug :fetch_event when action in [
    :show, :photo, :edit, :update, :delete]

  def fetch_event(conn, _args) do
    id = conn.params["id"]
    event = Users.get_event!(id)
    assign(conn, :event, event)
  end

  def index(conn, _params) do
    events = Users.list_events()
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    IO.puts("new")
    changeset = Users.change_event(%Event{})
    IO.inspect(changeset)
    ret = render(conn, "new.html", changeset: changeset)
    IO.puts("done new render")
    ret
  end

  def create(conn, %{"event" => event_params}) do
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
    event = Users.get_event!(id)
    render(conn, "show.html", event: event)
  end

  def edit(conn, %{"id" => id}) do
    event = Users.get_event!(id)
    changeset = Users.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Users.get_event!(id)

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
    event = Users.get_event!(id)
    {:ok, _event} = Users.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
