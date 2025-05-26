defmodule Pollutiondb.Reading do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Pollutiondb.Repo

  schema "readings" do
    field :date, :date
    field :time, :time
    field :type, :string
    field :value, :float

    belongs_to :station, Pollutiondb.Station

  end

  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [:date, :time, :type, :value, :station_id])
    |> validate_required([:date, :time, :type, :value, :station_id])
  end

  def add_reading(station_id, date, time, type, value) do
    %__MODULE__{}
    |> changeset(%{
      date: date,
      time: time,
      type: type,
      value: value,
      station_id: station_id
    })
    |> Pollutiondb.Repo.insert()
  end

  def add_now(station, type, value) do
    %__MODULE__{}
    |> changeset(%{
      date: Date.utc_today(),
      time: Time.truncate(Time.utc_now(), :second),
      type: type,
      value: value,
      station_id: station.id
    })
    |> Pollutiondb.Repo.insert()
  end

  def find_by_date(date) do
    from(r in __MODULE__, where: r.date == ^date, preload: [:station])
    |> Pollutiondb.Repo.all()
  end

  def get_10_latest() do
    from(r in __MODULE__,
      limit: 10,
      order_by: [desc: r.date, desc: r.time]
    )
    |> Repo.all()
    |> Repo.preload(:station)
  end

  def get_10_latest_by_date(date) do
    from(r in __MODULE__,
      where: r.date == ^date,
      order_by: [desc: r.time],
      limit: 10
    )
    |> Repo.all()
    |> Repo.preload(:station)
  end

end
