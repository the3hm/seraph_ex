# Item Seed-Based Randomization Game Plan

## Overview

This document outlines the implementation plan for adding seed-based randomization to item damage and armor values. The goal is to make items more interesting while maintaining consistency across game restarts.

## Current System

### Damage System
- Damage is handled through effects with kind "damage"
- Each damage effect has:
  - `type`: The damage type (e.g., "slashing", "piercing")
  - `amount`: The base damage amount
- Damage is modified by character stats and random swing

### Armor System
- Armor items have:
  - `slot`: The equipment slot
  - `armor`: The base armor value
- Armor can have stat boosts and damage type resistances

## Implementation Plan

### 1. Schema Updates

#### A. Item Schema (`lib/data/item.ex`)
```elixir
# Add seed field to Item schema
schema "items" do
  # ... existing fields ...
  field :seed, Ecto.UUID, read_after_writes: true
  timestamps()
end

# Update changeset to generate seed if not present
def changeset(struct, params) do
  struct
  |> cast(params, [...existing_fields..., :seed])
  |> validate_required([...existing_fields...])
  |> put_seed()
end

defp put_seed(changeset) do
  case get_change(changeset, :seed) do
    nil -> put_change(changeset, :seed, Ecto.UUID.generate())
    _ -> changeset
  end
end
```

#### B. Stats Schema Updates
```elixir
# Update weapon stats structure
%{
  "damage" => %{
    "base" => integer(),
    "variance" => integer(),
    "type" => String.t()
  }
}

# Update armor stats structure
%{
  "armor" => %{
    "base" => integer(),
    "variance" => integer()
  },
  "slot" => atom()
}
```

### 2. Validator Updates

#### A. Stats Validator (`lib/data/stats.ex`)
```elixir
def valid_weapon?(stats) do
  case stats do
    %{"damage" => %{"base" => base, "variance" => variance, "type" => type}} 
    when is_integer(base) and is_integer(variance) and is_binary(type) ->
      base > 0 and variance >= 0
    _ -> false
  end
end

def valid_armor?(stats) do
  case stats do
    %{"armor" => %{"base" => base, "variance" => variance}, "slot" => slot} 
    when is_integer(base) and is_integer(variance) ->
      base > 0 and variance >= 0 and valid_slot?(%{slot: slot})
    _ -> false
  end
end
```

### 3. Randomization Implementation

#### A. Random Number Generator (`lib/game/random.ex`)
```elixir
defmodule Game.Random do
  @moduledoc """
  Deterministic random number generation using seeds
  """

  def with_seed(seed, fun) do
    <<a::32, b::32, c::32>> = :crypto.hash(:sha256, seed)
    {seed_state, _} = :rand.seed_s(:exs1024, {a, b, c})
    {result, _} = :rand.seed_s(seed_state, fun.())
    result
  end

  def random_range(min, max) do
    :rand.uniform_s(max - min + 1) + min - 1
  end
end
```

#### B. Item Compilation (`lib/data/item/compiled.ex`)
```elixir
def compile(item) do
  compiled_item = struct(__MODULE__, Map.take(item, @fields))
  
  Game.Random.with_seed(item.seed, fn ->
    compiled_item
    |> merge_stats(item)
    |> merge_effects(item)
  end)
end

defp merge_stats(compiled_item, %{item_aspectings: item_aspectings}) do
  stats = Enum.reduce(
    item_aspectings,
    compiled_item.stats,
    &_merge_stats(&1, &2, compiled_item.level)
  )
  %{compiled_item | stats: stats}
end

defp _merge_stats(%{item_aspect: %{type: "armor", stats: stats}}, acc_stats, level) do
  base = stats.armor.base
  variance = stats.armor.variance
  armor = Game.Random.random_range(base - variance, base + variance)
  armor = scale_for_level(level, armor)
  %{acc_stats | armor: acc_stats.armor + armor}
end
```

### 4. Effect Calculation Updates

#### A. Damage Calculation (`lib/game/effect.ex`)
```elixir
def calculate_damage(effect, stats) do
  case DamageTypes.get(effect.type) do
    {:ok, damage_type} ->
      stat = Map.get(stats, damage_type.stat_modifier)
      base = effect.amount.base
      variance = effect.amount.variance
      damage = Game.Random.random_range(base - variance, base + variance)
      modifier = 1 + stat / damage_type.boost_ratio
      modified_amount = max(round(Float.ceil(damage * modifier)), 0)
      effect |> Map.put(:amount, modified_amount)
    _ ->
      effect
  end
end
```

### 5. Admin Panel Updates

#### A. Item Form (`lib/web/templates/admin/item/_form.html.eex`)
```elixir
# Add variance fields for damage and armor
<div class="form-group">
  <%= label f, :damage_variance, class: "col-md-4" %>
  <div class="col-md-8">
    <%= number_input f, :damage_variance, class: "form-control" %>
    <span class="help-block">How much the damage can vary from base</span>
  </div>
</div>

<div class="form-group">
  <%= label f, :armor_variance, class: "col-md-4" %>
  <div class="col-md-8">
    <%= number_input f, :armor_variance, class: "form-control" />
    <span class="help-block">How much the armor can vary from base</span>
  </div>
</div>
```

### 6. Migration Plan

1. Create migration for adding seed field:
```elixir
defmodule Data.Repo.Migrations.AddSeedToItems do
  use Ecto.Migration

  def up do
    # Enable UUID extension
    execute "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
    
    # Backup existing items
    execute """
    CREATE TABLE items_backup AS 
    SELECT * FROM items;
    """
    
    # Add seed field
    alter table(:items) do
      add :seed, :uuid
    end
    
    # Generate seeds for existing items
    execute """
    UPDATE items 
    SET seed = uuid_generate_v4() 
    WHERE seed IS NULL
    """
    
    # Make seed field required
    alter table(:items) do
      modify :seed, :uuid, null: false
    end
    
    # Create index on seed field
    create index(:items, :seed)
  end

  def down do
    # Remove index
    drop index(:items, :seed)
    
    # Remove seed field
    alter table(:items) do
      remove :seed
    end
    
    # Restore from backup
    execute """
    INSERT INTO items 
    SELECT * FROM items_backup;
    """
    
    # Drop backup table
    drop table(:items_backup)
    
    # Drop UUID extension
    execute "DROP EXTENSION IF EXISTS \"uuid-ossp\";"
  end
end
```

2. Update existing items to use new stats structure:
```elixir
defmodule Data.Repo.Migrations.UpdateItemStats do
  use Ecto.Migration

  def up do
    # Backup existing items
    execute """
    CREATE TABLE items_backup AS 
    SELECT * FROM items;
    """
    
    # Update weapon stats
    execute """
    UPDATE items 
    SET stats = jsonb_set(
      stats,
      '{damage}',
      jsonb_build_object(
        'base', (stats->>'damage')::integer,
        'variance', 0,
        'type', 'slashing'
      )
    )
    WHERE type = 'weapon'
    """

    # Update armor stats
    execute """
    UPDATE items 
    SET stats = jsonb_set(
      stats,
      '{armor}',
      jsonb_build_object(
        'base', (stats->>'armor')::integer,
        'variance', 0
      )
    )
    WHERE type = 'armor'
    """
    
    # Validate updates
    execute """
    DO $$
    BEGIN
      IF EXISTS (
        SELECT 1 FROM items 
        WHERE type = 'weapon' 
        AND NOT (stats->'damage' ? 'base' AND stats->'damage' ? 'variance' AND stats->'damage' ? 'type')
      ) THEN
        RAISE EXCEPTION 'Invalid weapon stats structure';
      END IF;
      
      IF EXISTS (
        SELECT 1 FROM items 
        WHERE type = 'armor' 
        AND NOT (stats->'armor' ? 'base' AND stats->'armor' ? 'variance')
      ) THEN
        RAISE EXCEPTION 'Invalid armor stats structure';
      END IF;
    END $$;
    """
  end

  def down do
    # Restore from backup
    execute """
    INSERT INTO items 
    SELECT * FROM items_backup;
    """
    
    # Drop backup table
    drop table(:items_backup)
  end
end
```

## Testing Plan

1. Unit Tests:
   - Test seed generation and validation
   - Test random number generation with same seed
   - Test stats validation for new structure
   - Test damage and armor calculations

2. Integration Tests:
   - Test item compilation with seeds
   - Test effect calculation with randomized values
   - Test admin panel form updates

3. Property-Based Tests:
   - Test deterministic behavior with same seed
   - Test different seeds produce different values
   - Test value ranges stay within bounds

4. Manual Testing:
   - Create items with different variance values
   - Verify randomization is consistent across restarts
   - Test edge cases (min/max values)

## Rollout Strategy

1. Development:
   - Implement schema changes
   - Update validators
   - Add randomization logic
   - Update admin panel

2. Testing:
   - Run unit tests
   - Run integration tests
   - Run property-based tests
   - Manual testing in development environment

3. Staging:
   - Deploy to staging environment
   - Test with existing items
   - Verify migration scripts
   - Run dry-run verification task

4. Production:
   - Schedule maintenance window
   - Run migrations
   - Deploy code changes
   - Monitor for issues

## Future Considerations

1. Performance:
   - Monitor random number generation impact
   - Consider caching compiled items

2. Balance:
   - Monitor item power levels
   - Adjust variance ranges if needed

3. Features:
   - Add more randomization options
   - Consider adding quality levels
   - Add visual indicators for randomized values 