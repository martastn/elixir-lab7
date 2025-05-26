defmodule PollutiondbWeb.ReadingLive do
  use PollutiondbWeb, :live_view
  alias Pollutiondb.{Reading, Station, Repo}


  def mount(_params, _session, socket) do
    today = Date.utc_today()
    readings = Reading.get_10_latest()
    stations = Repo.all(Station)

    socket =
      assign(socket,
        readings: readings,
        date: Date.to_string(today),
        type: "PM10",
        value: "0.0",
        station_id: nil,
        stations: stations
      )

    {:ok, socket}
  end

  def handle_event("add_reading", %{"reading" => reading_params}, socket) do
    type = reading_params["type"] || "PM10"
    value = to_float(reading_params["value"], 0.0)
    station_id = to_int(reading_params["station_id"], 1)

    station = %Station{id: station_id}

    {:ok, _} = Reading.add_now(station, type, value)

    socket =
      assign(socket,
        readings: Reading.get_10_latest(),
        type: type,
        value: "",
        station_id: station_id
      )

    {:noreply, socket}
  end


  def handle_event("set_date", %{"date" => date_str}, socket) do
    date = to_date(date_str)

    socket =
      assign(socket,
        readings: Reading.get_10_latest_by_date(date),
        date: Date.to_string(date)
      )

    {:noreply, socket}
  end

  defp to_int(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {number, _} -> number
      :error -> default
    end
  end
  defp to_int(_, default), do: default

  defp to_float(value, default) when is_binary(value) do
    case Float.parse(value) do
      {number, _} -> number
      :error -> default
    end
  end
  defp to_float(_, default), do: default


  defp to_date(nil), do: Date.utc_today()
  defp to_date(""), do: Date.utc_today()

  defp to_date(date_str) do
    case Date.from_iso8601(date_str) do
      {:ok, date} -> date
      _ -> Date.utc_today()
    end
  end

  def render(assigns) do
    ~H"""
    <div style="max-width: 600px; margin: 0 auto;">
      <h1>Readings</h1>

      <form phx-submit="add_reading" style="display: flex; flex-direction: column; gap: 0.5rem; margin-bottom: 2rem;">
        <h2>Add reading</h2>

        <div style="display: flex; gap: 1rem;">
          <div style="flex: 1;">
            <label>Type:</label>
            <input type="text" name="reading[type]" value={@type} style="width: 100%;" />
          </div>

          <div style="flex: 1;">
            <label>Value:</label>
            <input type="text" name="reading[value]" value={@value} style="width: 100%;" />
          </div>
        </div>

        <div style="display: flex; gap: 1rem; align-items: flex-end;">
          <div style="flex: 1;">
            <label>Station:</label>
            <select name="reading[station_id]" style="width: 100%;">
              <%= for station <- @stations do %>
                <option value={station.id} selected={station.id == @station_id}><%= station.name %></option>
              <% end %>
            </select>
          </div>

          <button type="submit" style="padding: 0.5rem 1rem;">Dodaj</button>
        </div>
      </form>

      <h2>Find reading by date</h2>
      <form phx-change="set_date" style="margin-bottom: 1rem;">
        <label for="date">Date:</label>
        <input type="date" name="date" value={@date} />
      </form>

      <table border="1" cellpadding="5" cellspacing="0" style="width: 100%; border-collapse: collapse;">
        <thead style="background-color: #f0f0f0;">
          <tr>
            <th>Station</th>
            <th>Date</th>
            <th>Time</th>
            <th>Type</th>
            <th>Value</th>
          </tr>
        </thead>
        <tbody>
          <%= for r <- @readings do %>
            <tr>
              <td><%= r.station.name %></td>
              <td><%= r.date %></td>
              <td><%= r.time %></td>
              <td><%= r.type %></td>
              <td><%= r.value %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

end
