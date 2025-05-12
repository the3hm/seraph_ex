defmodule Data.Repo.Migrations.AllowNullEffectsOnItems do
  use Ecto.Migration

  def up do
    alter table(:items) do
      modify :effects, {:array, :map}, null: true
    end
  end

  def down do
    alter table(:items) do
      modify :effects, {:array, :map}, null: false, default: fragment("'{}'")
    end
  end
end
