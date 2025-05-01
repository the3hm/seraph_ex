# Quest System Documentation

## Quest Objectives

The quest system supports several types of objectives that players can complete. Each objective type has specific requirements and tracking mechanisms.

### Current Objective Types

#### 1. Item Collection Objectives

##### item/collect
- **Purpose**: Players must have specific items in their inventory when completing the quest
- **Behavior**: Items are automatically removed from the player's inventory upon quest completion
- **Implementation**: 
  - Tracks items in player's inventory
  - Removes items on quest completion
  - Validates item presence before allowing completion

##### item/give
- **Purpose**: Players must give items to a specific NPC
- **Behavior**: Tracks items given to NPCs in quest progress
- **Implementation**:
  - Monitors item transfers to specific NPCs
  - Updates quest progress when items are given
  - Validates NPC identity and item requirements

##### item/have
- **Purpose**: Players must possess items when turning in the quest
- **Behavior**: Items remain in player's inventory after quest completion
- **Implementation**:
  - Validates item presence in inventory
  - Does not remove items on completion
  - Simple presence check without tracking

#### 2. Combat Objectives

##### npc/kill
- **Purpose**: Players must defeat specific NPCs a certain number of times
- **Behavior**: Tracks NPC kills and updates progress
- **Implementation**:
  - Monitors combat events
  - Validates NPC identity
  - Increments kill counter
  - Updates quest progress

#### 3. Exploration Objectives

##### room/explore
- **Purpose**: Players must visit specific rooms
- **Behavior**: Tracks room visits and saves progress
- **Implementation**:
  - Monitors player movement
  - Validates room identity
  - Updates quest progress on room entry
  - Persists progress

## Extending Quest Objectives

To add new quest objective types, follow these steps:

1. **Define Objective Type**
   - Create a new module in `lib/game/quest/objective/`
   - Implement the `Game.Quest.Objective` behavior
   - Define required callbacks

2. **Required Callbacks**
   ```elixir
   defmodule Game.Quest.Objective.YourObjective do
     @behaviour Game.Quest.Objective
     
     # Called when quest is started
     def start(quest, step, player) do
       # Initialize tracking
     end
     
     # Called when checking if objective is complete
     def is_complete?(quest, step, player) do
       # Check completion conditions
     end
     
     # Called when quest is completed
     def complete(quest, step, player) do
       # Handle completion effects
     end
   end
   ```

3. **Register Objective Type**
   - Add to `Game.Quest.Objective.types/0`
   - Include in admin panel options
   - Update documentation

4. **Example Implementation**
   ```elixir
   defmodule Game.Quest.Objective.Example do
     @behaviour Game.Quest.Objective
     
     def start(quest, step, player) do
       # Initialize tracking
       {:ok, %{progress: 0}}
     end
     
     def is_complete?(quest, step, player) do
       # Check completion conditions
       progress = get_progress(player, quest, step)
       progress >= step.required_count
     end
     
     def complete(quest, step, player) do
       # Handle completion effects
       {:ok, player}
     end
   end
   ```

5. **Testing Considerations**
   - Test objective initialization
   - Verify completion conditions
   - Test edge cases
   - Ensure proper cleanup

## Best Practices

1. **State Management**
   - Keep objective state minimal
   - Use persistent storage when needed
   - Clean up temporary state

2. **Error Handling**
   - Handle edge cases gracefully
   - Log errors appropriately
   - Provide clear feedback

3. **Performance**
   - Optimize frequent checks
   - Cache expensive operations
   - Use efficient data structures

4. **Documentation**
   - Document objective behavior
   - Provide usage examples
   - Include edge cases

## Common Patterns

1. **Progress Tracking**
   ```elixir
   def track_progress(player, quest, step, amount) do
     current = get_progress(player, quest, step)
     new_progress = min(current + amount, step.required_count)
     save_progress(player, quest, step, new_progress)
   end
   ```

2. **State Validation**
   ```elixir
   def validate_state(player, quest, step) do
     case get_state(player, quest, step) do
       {:ok, state} -> {:ok, state}
       :error -> initialize_state(player, quest, step)
     end
   end
   ```

3. **Completion Effects**
   ```elixir
   def apply_completion_effects(player, quest, step) do
     player
     |> give_rewards(quest.rewards)
     |> update_stats(quest.stats)
     |> notify_completion()
   end
   ```

## Integration Points

1. **Event System**
   - Subscribe to relevant events
   - Update progress based on events
   - Handle event failures

2. **Player State**
   - Access player inventory
   - Check player stats
   - Update player progress

3. **Quest System**
   - Register objective types
   - Handle quest state
   - Manage progress tracking

4. **Admin Panel**
   - Add configuration options
   - Provide progress views
   - Enable manual updates 