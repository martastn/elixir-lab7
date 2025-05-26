defmodule PollutiondbWeb.StationLive do
  use PollutiondbWeb, :live_view

  alias Pollutiondb.Station

  def mount(_params, _session, socket) do
    socket = assign(socket, stations: Station.get_all(), name: "", lat: "", lon: "", name_to_find: "")
    {:ok, socket}
  end

  defp to_float(value, default) when is_binary(value) do
    case Float.parse(value) do
      {number, _} -> number
      :error -> default
    end
  end
  defp to_float(_, default), do: default


  def handle_event("insert", %{"name" => name, "lat" => lat, "lon" => lon}, socket) do
    Station.add(%Station{name: name, lat: to_float(lat, 0.0), lon: to_float(lon, 0.0)})
    socket = assign(socket, stations: Station.get_all(), name: name, lat: lat, lon: lon)
    {:noreply, socket}
  end

  def handle_event("find_by_name", %{"name_to_find" => name_to_find}, socket) do
    stations =
      if name_to_find == "" do
        Station.get_all()
      else
        Station.find_by_name(name_to_find)
      end

    {:noreply, assign(socket, name_to_find: name_to_find, stations: stations)}
  end

  def render(assigns) do
    ~H"""
    <div style="max-width: 600px; margin: 2rem auto; font-family: sans-serif;">
      <h2>Create new station</h2>
      <form phx-submit="insert" style="display: flex; flex-direction: column; gap: 0.5rem; margin-bottom: 2rem;">
        <label>
          Name:
          <input type="text" name="name" value={@name} style="width: 100%;" />
        </label>

        <label>
          Lat:
          <input type="number" name="lat" step="0.1" value={@lat} style="width: 100%;" />
        </label>

        <label>
          Lon:
          <input type="number" name="lon" step="0.1" value={@lon} style="width: 100%;" />
        </label>

        <input type="submit" value="Add" style="align-self: flex-start;" />
      </form>

      <h2>Find station by name</h2>
      <form phx-change="find_by_name" style="margin-bottom: 2rem;">
        <input
          type="text"
          name="name_to_find"
          value={@name_to_find}
          placeholder="Enter name:"
          style="width: 100%; padding: 0.5rem;"
        />
      </form>

      <h2>Stations</h2>
      <table border="1" cellpadding="6" cellspacing="0" style="width: 100%; border-collapse: collapse;">
        <thead style="background-color: #f0f0f0;">
          <tr>
            <th>Name</th>
            <th>Longitude</th>
            <th>Latitude</th>
          </tr>
        </thead>
        <tbody>
          <%= for station <- @stations do %>
            <tr>
              <td><%= station.name %></td>
              <td><%= station.lon %></td>
              <td><%= station.lat %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

end