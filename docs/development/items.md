# ExVenture Item System Documentation

## Overview

The ExVenture item system is a comprehensive implementation for managing in-game items, their properties, and interactions. The system is built using Elixir and follows a modular, data-driven approach.

## Core Components

### Data Layer (`lib/data/`)

1. **Item Schema** (`lib/data/item.ex`)
   - Base item definition
   - Core properties: name, description, type, level, keywords
   - Effect system integration
   - Item type validation
   - Stats and attributes

2. **Item Instances** (`lib/data/item/instance.ex`)
   - Runtime item instances
   - State management for in-game items
   - Instance-specific properties

3. **Item Aspects** (`lib/data/item_aspect.ex`)
   - Modular item properties
   - Aspect tagging system
   - Customizable item behaviors

### Game Logic Layer (`lib/game/`)

1. **Item Management** (`lib/game/items.ex`)
   - GenServer-based item cache
   - Item lookup and retrieval
   - Instance management
   - Cache synchronization

2. **Item Utilities** (`lib/game/item.ex`)
   - Item matching and lookup
   - Property validation
   - Item interaction helpers
   - Formatting utilities

3. **Item Events** (`lib/game/events/`)
   - Item dropped events
   - Item received events
   - Event handling system

## Item Types and Effects

### Supported Item Types
- Basic items
- Weapons
- Armor
- Resources
- Potions
- Books
- Baubles
- Jewelry (rings, necklaces, amulets)
- Runes
- Scrolls
- Gems
- Tattoos
- Equipment (belts, gloves, boots)

### Effect System
Each item type supports specific effects:
- Basic: Recovery effects
- Weapons: Damage, damage types, stats
- Armor: Stats, damage type resistance
- Potions: Stats, stat boosts, recovery over time
- Baubles: Stats, stat boosts, recovery effects
- Equipment: Various stat modifications

## Implementation Details

### Item Caching
```elixir
defmodule Game.Items do
  use GenServer
  
  # Cache management
  def item(id) do
    case Cachex.get(@key, id) do
      {:ok, item} when item != nil -> item
      _ -> nil
    end
  end
end
```

### Item Lookup
```elixir
defmodule Game.Item do
  def matches_lookup?(item, lookup) do
    [item.name | item.keywords]
    |> Enum.map(&String.downcase/1)
    |> Enum.any?(&Utility.matches?(&1, lookup))
  end
end
```

### Item Schema
```elixir
defmodule Data.Item do
  use Data.Schema
  
  schema "items" do
    field :name, :string
    field :description, :string
    field :type, :string
    field :level, :integer
    field :keywords, {:array, :string}
    # ... additional fields
  end
end
```

## Item Interactions

### Finding Items
- Keyword-based lookup
- Name matching
- Type filtering
- Level-based filtering

### Item Properties
- Base stats
- Effects
- Usage commands
- Tags and aspects
- Level requirements

### Item Management
- Creation and deletion
- Property modification
- Instance handling
- Cache updates

## Database Structure

### Core Tables
- `items` - Base item definitions
- `item_instances` - Runtime item instances
- `item_aspects` - Item properties and behaviors
- `item_aspectings` - Item-aspect relationships

### Migrations
- Item creation and modification
- Effect system integration
- Tag and aspect management
- Usage command support

## Testing

### Test Structure
- Unit tests for item logic
- Integration tests for item interactions
- Property validation tests
- Cache management tests

### Test Helpers
- Item creation helpers
- Property validation helpers
- Effect testing utilities

## Best Practices

1. **Item Creation**
   - Always validate item types
   - Ensure proper effect assignment
   - Set appropriate level requirements

2. **Item Management**
   - Use the cache system for performance
   - Validate item properties before saving
   - Handle item instances appropriately

3. **Effect Implementation**
   - Follow type-specific effect rules
   - Validate effect parameters
   - Test effect interactions

4. **Performance Considerations**
   - Leverage caching for frequently accessed items
   - Optimize database queries
   - Use appropriate indexes

## Future Considerations

1. **Potential Enhancements**
   - Advanced effect combinations
   - Item crafting system
   - Item quality levels
   - Item durability system

2. **Performance Optimizations**
   - Enhanced caching strategies
   - Query optimization
   - Batch processing improvements 