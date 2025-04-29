defmodule Data.Repo.Migrations.CreateWeatherTypes do
  use Ecto.Migration

  def change do
    create table(:weather_types) do
      add :name, :string, null: false
      add :description, :string, null: false
      add :valid_ecologies, {:array, :string}, null: false
      add :ecology_descriptions, :map, null: false, default: %{}
      add :effects, {:array, :integer}, null: false, default: []

      timestamps()
    end

    create index(:weather_types, [:name], unique: true)

    alter table(:zones) do
      add :weather_id, references(:weather_types, on_delete: :nilify_all)
    end
  end
end
