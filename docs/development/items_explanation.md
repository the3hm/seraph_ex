# Item System: Effects, Armor, and Slots

## Overview

The ExVenture item system implements a sophisticated mechanism for managing item effects, armor, and equipment slots. This document explains how these systems work and how to modify them.

## Whitelist Effects

### What are Whitelist Effects?

Whitelist effects are a filtering mechanism that determines which effects can be applied to an item. Each item can specify a list of allowed effect types in its `whitelist_effects` field.

### Implementation Details

- Stored as an array of strings in the `whitelist_effects` field
- Default value is an empty array `[]`
- Validates against known effect types
- Used to filter effects when applying them to items

### Example Usage

```elixir
# Valid whitelist effects
item = %Item{
  whitelist_effects: ["damage", "stats"]
}

# Invalid whitelist effects (will fail validation)
item = %Item{
  whitelist_effects: ["unknown_effect"]
}
```

### How to Modify

1. To add new effect types:
   - Add the effect type to the `Effect.types()` list
   - Update the validation in `Data.Item.validate_whitelist/1`

2. To change an item's whitelist:
   - Modify the `whitelist_effects` field in the item's data
   - Ensure all effects in the whitelist are valid types

## Armor System

### Armor Types and Properties

Armor items have specific properties:
- Must have a valid slot
- Must have an armor value
- Can only have specific effect types

### Valid Armor Stats

```elixir
%{
  slot: :chest,  # Must be one of the valid slots
  armor: 10      # Must be an integer
}
```

### Effect Types for Armor

Armor items can have the following effect types:
- `stats` - Modifies character statistics
- `damage/type` - Provides damage type resistance

### How to Modify

1. To add new armor slots:
   - Add the slot to `Stats.slots()`
   - Update the validation in `Stats.valid_slot?/1`

2. To change armor properties:
   - Modify the `stats` field in the armor item
   - Ensure the slot and armor values are valid

## Equipment Slots

### Available Slots

The system supports the following equipment slots:
- `:chest`
- `:head`
- `:shoulders`
- `:neck`
- `:back`
- `:hands`
- `:waist`
- `:legs`
- `:feet`
- `:leftfinger`
- `:rightfinger`
- `:goggles`

### Slot Management

- Each slot can hold one item
- Items must specify their slot in their stats
- Slots are validated when equipping items

### How to Modify

1. To add new slots:
   - Add the slot to `Stats.slots()`
   - Update the validation in `Stats.valid_slot?/1`
   - Update the UI to support the new slot

2. To modify slot behavior:
   - Update the `Command.Wear` module
   - Modify the slot validation logic

## Best Practices

1. **Effect Management**
   - Always validate effects against the whitelist
   - Use appropriate effect types for each item type
   - Test effect combinations thoroughly

2. **Armor Implementation**
   - Ensure armor values are balanced
   - Validate slot assignments
   - Test armor effects in combination

3. **Slot Management**
   - Keep slot names consistent
   - Validate slot assignments
   - Test equipment swapping

## Common Pitfalls

1. **Effect Validation**
   - Forgetting to update whitelist validation
   - Using invalid effect types
   - Not testing effect combinations

2. **Armor Implementation**
   - Invalid slot assignments
   - Missing armor values
   - Incorrect effect types

3. **Slot Management**
   - Duplicate slot names
   - Missing slot validation
   - Inconsistent slot handling

## Testing

When modifying these systems, ensure to test:
1. Effect whitelist validation
2. Armor stat validation
3. Slot assignment and management
4. Equipment swapping
5. Effect application and removal 