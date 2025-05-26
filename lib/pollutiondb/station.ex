defmodule Pollutiondb.Station do
  use Ecto.Schema
  import Ecto.Changeset
  alias Pollutiondb.Repo
  require Ecto.Query

  schema "stations" do
    field :name, :string
    field :lon, :float
    field :lat, :float

    has_many :readings, Pollutiondb.Reading

    timestamps()

  end


  defp changeset(station, params) do
    station
    |> cast(params, [:name, :lon, :lat])
    |> validate_required([:name, :lon, :lat])
    |> validate_number(:lon, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
    |> validate_number(:lat, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> unique_constraint(:name)
    |> unique_constraint([:lon, :lat], name: :stations_lon_lat_index)
  end


  def add(name, lon, lat) do
    %__MODULE__{}
    |> changeset(%{name: name, lon: lon, lat: lat})
    |> Repo.insert()
  end

  def add(%__MODULE__{} = station) do
    changeset(station, %{})
    |> Repo.insert()
  end

  def update_name(station, newname) do
    changeset(station, %{name: newname})
    |> Repo.update()
  end

  def get_all() do
    Repo.all(__MODULE__)
  end

  def get_all_with_readings() do
    __MODULE__
    |> Ecto.Query.preload(:readings)
    |> Repo.all()
  end


  def get_by_id(id) do
    Repo.get(__MODULE__, id)
  end

  def remove(station) do
    Repo.delete(station)
  end

  def find_by_name(name) do
    Repo.all(
      Ecto.Query.where(__MODULE__, name: ^name)
    )
  end

  def find_by_location(lon, lat) do
    Ecto.Query.from(s in __MODULE__,
      where: s.lon == ^lon and s.lat == ^lat)
    |> Repo.all()
  end

  def find_by_location_range(lon_min, lon_max, lat_min, lat_max) do
    Ecto.Query.from(s in __MODULE__,
      where: s.lon >= ^lon_min and s.lon <= ^lon_max
             and s.lat >= ^lat_min and s.lat <= ^lat_max)
    |> Repo.all()
  end

  def get_lat_lon_bounds() do
    import Ecto.Query

    query = from s in __MODULE__,
                 select: %{
                   lat_min: fragment("MIN(?)", s.lat),
                   lat_max: fragment("MAX(?)", s.lat),
                   lon_min: fragment("MIN(?)", s.lon),
                   lon_max: fragment("MAX(?)", s.lon)
                 }

    Repo.one(query)
  end
end




#alias Pollutiondb.Station
#
#{:ok, warszawa} = Station.add("Warszawa", 21.0122, 52.2297)
#{:ok, krakow} = Station.add("Kraków", 19.9445, 50.0497)
#{:ok, gdansk} = Station.add("Gdańsk", 18.6466, 54.3520)
#
#alias Pollutiondb.Reading
#
#Reading.add_reading(warszawa.id, ~D[2024-05-17], ~T[12:00:00], "PM10", 48.2)
#Reading.add_reading(warszawa.id, ~D[2024-05-17], ~T[18:00:00], "NO2", 20.5)
#
#Reading.add_reading(krakow.id, ~D[2024-05-17], ~T[14:30:00], "SO2", 12.0)
#Reading.add_reading(krakow.id, ~D[2024-05-17], ~T[15:00:00], "PM2.5", 36.1)
#
#Reading.add_reading(gdansk.id, ~D[2024-05-17], ~T[10:15:00], "O3", 70.0)
#
#Station.get_all()
#
#Station.get_all_with_readings()

#alias Pollutiondb.{Repo, Station, Reading}
#[st1, st2 | _] = Station.get_all()
#Reading.add_now(st1, "PM10", 41.5)
#Reading.add_now(st1, "NO2", 19.2)
#Reading.add_now(st2, "SO2", 7.8)
#Reading.find_by_date(Date.utc_today())

# Pollutiondb.Loader.load_from_file("priv/data/stations_data.json")