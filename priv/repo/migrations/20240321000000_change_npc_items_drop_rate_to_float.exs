defmodule Data.Repo.Migrations.ChangeNpcItemsDropRateToFloat do
  use Ecto.Migration

  def up do
    # Clear any cached plans
    execute "DEALLOCATE ALL"

    # Convert existing integer values to float
    execute "ALTER TABLE npc_items ALTER COLUMN drop_rate TYPE float USING drop_rate::float"
    execute "ALTER TABLE npc_items ALTER COLUMN drop_rate SET DEFAULT 10.0"
  end

  def down do
    # Clear any cached plans
    execute "DEALLOCATE ALL"

    # Convert back to integer, rounding to nearest integer
    execute "ALTER TABLE npc_items ALTER COLUMN drop_rate TYPE integer USING round(drop_rate)::integer"
    execute "ALTER TABLE npc_items ALTER COLUMN drop_rate SET DEFAULT 10"
  end
end
