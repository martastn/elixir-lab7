defmodule Pollutiondb.Repo.Migrations.CreateStations do
  use Ecto.Migration

  def change do
    create table(:stations) do
      add :name, :string, null: false
      add :lon, :float, null: false
      add :lat, :float, null: false
      timestamps()
    end

    #create unique_index(:stations, [:name])
    #create unique_index(:stations, [:lon, :lat])
  end

end
