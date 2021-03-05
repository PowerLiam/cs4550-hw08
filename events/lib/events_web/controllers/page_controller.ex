defmodule EventsWeb.PageController do
  use EventsWeb, :controller

  alias Events.Users

  def index(conn, _params) do
    events = Users.list_events()
    render(conn, "index.html", events: events)
  end
end
