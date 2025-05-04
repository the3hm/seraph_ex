# Effects System Documentation

## Overview

The ExVenture effects system provides a flexible and powerful way to implement various in-game effects for items, skills, and other game mechanics. This document explains the current effects, how they work, and how to create new ones.

## Current Effect Types

### 1. Damage Effects

#### Basic Damage (`damage`)
```elixir
%{
  kind: "damage",
  type: "slashing",  # Damage type (e.g., slashing, bludgeoning, arcane)
  amount: 10        # Base damage amount
}
```
- Applies instant damage to a target
- Damage type affects which stats modify the damage
- Physical damage types (slashing, bludgeoning) use strength
- Magical damage types (arcane, fire) use intelligence

#### Damage Type (`damage/type`)
```elixir
%{
  kind: "damage/type",
  types: ["slashing", "bludgeoning"]  # List of allowed damage types
}
```
- Restricts which damage types can be used effectively
- If damage type doesn't match, damage is halved
- Useful for class/role restrictions

#### Damage Over Time (`damage/over-time`)
```elixir
%{
  kind: "damage/over-time",
  type: "slashing",
  amount: 10,
  every: 1000,  # Milliseconds between ticks
  count: 3      # Number of ticks
}
```
- Applies damage periodically
- Tracks duration and remaining ticks
- Can be removed by death or completion

### 2. Recovery Effects

#### Basic Recovery (`recover`)
```elixir
%{
  kind: "recover",
  type: "health",  # health, skill, or endurance
  amount: 10
}
```
- Instantly recovers points
- Can target health, skill, or endurance
- Modified by awareness stat

#### Recovery Over Time (`recover/over-time`)
```elixir
%{
  kind: "recover/over-time",
  type: "health",
  amount: 10,
  every: 1000,
  count: 3
}
```
- Applies recovery periodically
- Similar structure to damage over time
- Also modified by awareness

### 3. Stat Effects

#### Basic Stats (`stats`)
```elixir
%{
  kind: "stats",
  field: :strength,
  amount: 10,
  mode: "add"  # add, subtract, multiply, divide
}
```
- Modifies base stats
- Applied before other effects
- Supports multiple operation modes

#### Stat Boost (`stats/boost`)
```elixir
%{
  kind: "stats/boost",
  field: :strength,
  amount: 10,
  duration: 1000,  # Duration in milliseconds
  mode: "add"
}
```
- Temporary stat modification
- Tracks duration
- Can be removed by death or completion

## Creating New Effects

### 1. Define the Effect Type

1. Add the new effect type to `Data.Effect.types()`
2. Create a new type specification in `Data.Effect`
3. Add validation logic in `Data.Effect.valid?/1`

### 2. Implement Effect Logic

1. Add calculation logic in `Game.Effect.calculate/2`
2. Implement effect application in `Game.Effect.apply_effect/2`
3. Add formatting in `Game.Format.Effects.render/2`

### 3. Update UI Components

1. Create a new React component in `assets/admin/js/effects.jsx`
2. Add the component to the `Effect` class render method
3. Update the `AddEffect` class to support the new effect

## Example: Creating a New Effect

Let's create a "mana drain" effect as an example:

```elixir
# 1. Add to types list
def types() do
  [
    "damage",
    "damage/over-time",
    "damage/type",
    "recover/over-time",
    "recover",
    "stats",
    "stats/boost",
    "mana-drain"  # New effect
  ]
end

# 2. Add type specification
@type mana_drain :: %{
  kind: String.t(),
  amount: integer(),
  duration: integer()
}

# 3. Add validation
def valid?(effect = %{kind: "mana-drain"}) do
  keys(effect) == [:kind, :amount, :duration] && 
  is_integer(effect.amount) && 
  is_integer(effect.duration)
end

# 4. Add calculation logic
def calculate(effect = %{kind: "mana-drain"}, stats) do
  # Calculate mana drain based on stats
  modified_amount = calculate_mana_drain(effect.amount, stats)
  %{effect | amount: modified_amount}
end

# 5. Add application logic
def apply_effect(effect = %{kind: "mana-drain"}, stats) do
  %{stats | skill_points: stats.skill_points - effect.amount}
end
```

## New Effect Ideas

Here are 10 new effect ideas that could enhance the game:

1. **Elemental Absorption**
   ```elixir
   %{
     kind: "elemental-absorption",
     type: "fire",  # Element type
     amount: 20,    # Percentage absorbed
     duration: 5000
   }
   ```
   - Absorbs a percentage of incoming elemental damage
   - Converts absorbed damage to healing

2. **Stat Swap**
   ```elixir
   %{
     kind: "stat-swap",
     from: :strength,
     to: :intelligence,
     duration: 10000
   }
   ```
   - Temporarily swaps two stats
   - Useful for hybrid builds

3. **Damage Reflection**
   ```elixir
   %{
     kind: "damage-reflection",
     percentage: 30,
     duration: 3000
   }
   ```
   - Reflects a percentage of incoming damage
   - Works with all damage types

4. **Skill Cooldown Reduction**
   ```elixir
   %{
     kind: "cooldown-reduction",
     percentage: 20,
     duration: 8000
   }
   ```
   - Reduces skill cooldown times
   - Stacks multiplicatively

5. **Experience Boost**
   ```elixir
   %{
     kind: "experience-boost",
     percentage: 50,
     duration: 3600000  # 1 hour
   }
   ```
   - Increases experience gain
   - Rare and valuable effect

6. **Critical Chance**
   ```elixir
   %{
     kind: "critical-chance",
     percentage: 15,
     duration: 5000
   }
   ```
   - Increases critical hit chance
   - Works with all damage types

7. **Status Effect Immunity**
   ```elixir
   %{
     kind: "status-immunity",
     types: ["poison", "stun"],
     duration: 10000
   }
   ```
   - Provides immunity to specific status effects
   - Configurable for different effects

8. **Resource Generation**
   ```elixir
   %{
     kind: "resource-generation",
     type: "skill",
     amount: 5,
     every: 2000,
     count: 5
   }
   ```
   - Generates resources over time
   - Works with health, skill, or endurance

9. **Damage Conversion**
   ```elixir
   %{
     kind: "damage-conversion",
     from: "physical",
     to: "arcane",
     percentage: 50,
     duration: 8000
   }
   ```
   - Converts a percentage of damage to another type
   - Useful for hybrid builds

10. **Stat Scaling**
    ```elixir
    %{
      kind: "stat-scaling",
      field: :strength,
      scale: 1.5,  # Multiplier
      duration: 6000
    }
    ```
    - Multiplies a stat by a factor
    - Temporary but powerful boost

## Best Practices

1. **Effect Design**
   - Keep effects simple and focused
   - Ensure clear interaction with existing systems
   - Consider balance implications

2. **Implementation**
   - Follow the existing pattern for new effects
   - Add comprehensive validation
   - Include proper error handling

3. **Testing**
   - Test all effect combinations
   - Verify stat interactions
   - Check edge cases

4. **Documentation**
   - Document all new effect types
   - Include usage examples
   - Note any special considerations

## Common Pitfalls

1. **Balance Issues**
   - Overpowered effects
   - Unintended combinations
   - Scaling problems

2. **Implementation Errors**
   - Missing validation
   - Incorrect stat calculations
   - Improper duration handling

3. **Performance Concerns**
   - Too many continuous effects
   - Complex calculations
   - Resource-intensive operations 