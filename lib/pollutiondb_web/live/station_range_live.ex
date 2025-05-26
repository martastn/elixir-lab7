defmodule PollutiondbWeb.StationRangeLive do
  use PollutiondbWeb, :live_view

  alias Pollutiondb.Station


  def mount(_params, _session, socket) do
    bounds = Station.get_lat_lon_bounds()

    socket =
      assign(socket,
        stations: Station.get_all(),
        lat_min: bounds.lat_min,
        lat_max: bounds.lat_max,
        lon_min: bounds.lon_min,
        lon_max: bounds.lon_max,
        general_lat_min: bounds.lat_min - 1,
        general_lat_max: bounds.lat_max + 1,
        general_lon_min: bounds.lon_min - 1,
        general_lon_max: bounds.lon_max + 1
      )

    {:ok, socket}
  end



  defp to_float(value, default) when is_binary(value) do
    case Float.parse(value) do
      {number, _} -> number
      :error -> default
    end
  end
  defp to_float(_, default), do: default


  def handle_event("update", params, socket) do
    lat_min = to_float(Map.get(params, "lat_min"), socket.assigns.lat_min)
    lat_max = to_float(Map.get(params, "lat_max"), socket.assigns.lat_max)
    lon_min = to_float(Map.get(params, "lon_min"), socket.assigns.lon_min)
    lon_max = to_float(Map.get(params, "lon_max"), socket.assigns.lon_max)

    stations = Station.find_by_location_range(lon_min, lon_max, lat_min, lat_max)

    socket =
      assign(socket, lat_min: lat_min, lat_max: lat_max, lon_min: lon_min, lon_max: lon_max, stations: stations )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div style="max-width: 600px; margin: 2rem auto; font-family: sans-serif;">
      <h2>Filtruj po współrzędnych</h2>
      <form phx-change="update" style="display: flex; flex-direction: column; gap: 1rem; margin-bottom: 2rem;">
        <label>
          Lat min:
          <input type="range" min={@general_lat_min} max={@general_lat_max} name="lat_min" value={@lat_min} style="width: 100%;" />
        </label>

        <label>
          Lat max:
          <input type="range" min={@general_lat_min} max={@general_lat_max} name="lat_max" value={@lat_max} style="width: 100%;" />
        </label>

        <label>
          Lon min:
          <input type="range" min={@general_lon_min} max={@general_lon_max} name="lon_min" value={@lon_min} style="width: 100%;" />
        </label>

        <label>
          Lon max:
          <input type="range" min={@general_lon_min} max={@general_lon_max} name="lon_max" value={@lon_max} style="width: 100%;" />
        </label>
      </form>

      <h2>Stacje</h2>
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