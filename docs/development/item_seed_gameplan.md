# Item Effect Variance Game Plan

## Overview

This document outlines the implementation plan for adding variance to item effects, making them more interesting while maintaining consistency across game restarts. The goal is to add variance directly to the existing effects system rather than creating a separate stats system.

## Current System

### Effects System
- Damage effects with type and amount
- Recovery effects with type and amount
- Stat effects with field, mode, and amount
- Effects are modified by character stats and random swing

## Implementation Plan

### 1. Effect Schema Updates

#### A. Update Effect Structure
```elixir
# Update damage effect structure
%{
  "kind" => "damage",
  "type" => String.t(),
  "amount" => %{
    "base" => integer(),
    "variance" => integer(),
    "min" => integer(),  # Optional, for UI display
    "max" => integer()   # Optional, for UI display
  }
}

# Update recover effect structure
%{
  "kind" => "recover",
  "type" => atom(),
  "amount" => %{
    "base" => integer(),
    "variance" => integer(),
    "min" => integer(),  # Optional, for UI display
    "max" => integer()   # Optional, for UI display
  }
}
```

### 2. Effect Validator Updates

#### A. Update Effect Validator (`lib/data/effect.ex`)
```elixir
def valid_damage?(effect) do
  case effect do
    %{type: type, amount: %{base: base, variance: variance}} 
    when is_binary(type) and is_integer(base) and is_integer(variance) ->
      base > 0 and variance >= 0
    %{type: type, amount: amount} when is_binary(type) and is_integer(amount) ->
      amount > 0
    _ -> false
  end
end

def valid_recover?(effect) do
  case effect do
    %{type: type, amount: %{base: base, variance: variance}} 
    when type in ["health", "skill", "move"] and is_integer(base) and is_integer(variance) ->
      base > 0 and variance >= 0
    %{type: type, amount: amount} 
    when type in ["health", "skill", "move"] and is_integer(amount) ->
      amount > 0
    _ -> false
  end
end
```

### 3. Effect Calculation Updates

#### A. Update Effect Calculation (`lib/game/effect.ex`)
```elixir
def calculate_damage(effect, stats) do
  case DamageTypes.get(effect.type) do
    {:ok, damage_type} ->
      stat = Map.get(stats, damage_type.stat_modifier)
      random_swing = Enum.random(@random_effect_range)
      modifier = 1 + stat / damage_type.boost_ratio + random_swing / 100

      # Handle both old and new amount structures
      amount = case effect.amount do
        %{base: base, variance: variance} ->
          Game.Random.random_range(base - variance, base + variance)
        amount when is_integer(amount) ->
          amount
      end

      modified_amount = max(round(Float.ceil(amount * modifier)), 0)
      effect |> Map.put(:amount, modified_amount)

    _ ->
      effect
  end
end
```

### 4. Admin Panel Updates

#### A. Update Effect Form (`assets/admin/js/effects.jsx`)
```jsx
class DamageEffect extends BaseEffect {
  constructor(props) {
    super(props);
    let effect = props.effect;
    this.state = {
      kind: "damage",
      type: effect.type,
      amount: effect.amount.base || effect.amount,
      variance: effect.amount.variance || 0
    };
  }

  render() {
    return (
      <div className="form-group row">
        <label className="col-md-4">Kind: damage</label>
        <div className="col-md-8">
          <div className="row">
            <div className="col-md-4">
              <label>Damage Type</label>
              <input type="text" value={this.state.type} 
                     className="form-control" 
                     onChange={this.handleUpdateField("type")} />
            </div>
            <div className="col-md-4">
              <label>Base Amount</label>
              <input type="number" value={this.state.amount} 
                     className="form-control" 
                     onChange={this.handleUpdateField("amount")} />
            </div>
            <div className="col-md-4">
              <label>Variance</label>
              <input type="number" value={this.state.variance} 
                     className="form-control" 
                     onChange={this.handleUpdateField("variance")} />
            </div>
          </div>
        </div>
      </div>
    );
  }
}
```

### 5. Migration Plan

1. Create migration for updating effect structures:
```elixir
defmodule Data.Repo.Migrations.UpdateEffectStructures do
  use Ecto.Migration

  def up do
    # Update damage effects
    execute """
    UPDATE items 
    SET effects = jsonb_set(
      effects,
      '{amount}',
      jsonb_build_object(
        'base', (effects->>'amount')::integer,
        'variance', 0
      )
    )
    WHERE effects->>'kind' = 'damage'
    """

    # Update recover effects
    execute """
    UPDATE items 
    SET effects = jsonb_set(
      effects,
      '{amount}',
      jsonb_build_object(
        'base', (effects->>'amount')::integer,
        'variance', 0
      )
    )
    WHERE effects->>'kind' = 'recover'
    """
  end

  def down do
    # Revert damage effects
    execute """
    UPDATE items 
    SET effects = jsonb_set(
      effects,
      '{amount}',
      to_jsonb((effects->'amount'->>'base')::integer)
    )
    WHERE effects->>'kind' = 'damage'
    """

    # Revert recover effects
    execute """
    UPDATE items 
    SET effects = jsonb_set(
      effects,
      '{amount}',
      to_jsonb((effects->'amount'->>'base')::integer)
    )
    WHERE effects->>'kind' = 'recover'
    """
  end
end
```

## Testing Plan

1. Unit Tests:
   - Test effect validation for new structure
   - Test damage and recovery calculations with variance
   - Test random number generation

2. Integration Tests:
   - Test effect application with variance
   - Test admin panel form updates
   - Test migration scripts

3. Manual Testing:
   - Create items with different variance values
   - Verify randomization is consistent
   - Test edge cases (min/max values)

## Rollout Strategy

1. Development:
   - Implement effect structure changes
   - Update validators
   - Add variance calculation
   - Update admin panel

2. Testing:
   - Run unit tests
   - Run integration tests
   - Manual testing in development

3. Staging:
   - Deploy to staging
   - Test with existing items
   - Verify migration scripts

4. Production:
   - Schedule maintenance window
   - Run migrations
   - Deploy code changes
   - Monitor for issues

## Future Considerations

1. Performance:
   - Monitor random number generation impact
   - Consider caching calculated effects

2. Balance:
   - Monitor effect power levels
   - Adjust variance ranges if needed

3. Features:
   - Add more randomization options
   - Consider adding quality levels
   - Add visual indicators for randomized values 