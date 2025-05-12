defmodule Data.Repo.Migrations.UpdateItemEffectsToVarianceMap do
  use Ecto.Migration

  def up do
    execute """
    UPDATE items
    SET effects = (
      SELECT array_agg(
        CASE
          WHEN effect->>'kind' IN ('damage', 'damage/over-time', 'recover', 'recover/over-time')
            AND jsonb_typeof(effect->'amount') = 'number'
          THEN
            jsonb_set(effect, '{amount}', jsonb_build_object('base', (effect->>'amount')::integer, 'variance', 0))
          ELSE
            effect
        END
      )
      FROM unnest(effects) AS effect
    )
    WHERE effects IS NOT NULL;
    """
  end

  def down do
    execute """
    UPDATE items
    SET effects = (
      SELECT array_agg(
        CASE
          WHEN effect->>'kind' IN ('damage', 'damage/over-time', 'recover', 'recover/over-time')
            AND jsonb_typeof(effect->'amount') = 'object'
            AND (effect->'amount' ? 'base')
          THEN
            jsonb_set(effect, '{amount}', to_jsonb((effect->'amount'->>'base')::integer))
          ELSE
            effect
        END
      )
      FROM unnest(effects) AS effect
    )
    WHERE effects IS NOT NULL;
    """
  end
end
