# ExVenture Architecture Documentation

## Core Directory Structure

```
lib/
├── data/         # Core data structures and schemas
├── game/         # Game logic and commands
├── web/          # Web interfaces and templates
├── networking/   # Network handling and protocols
├── metrics/      # System metrics and monitoring
├── grapevine/    # Grapevine network integration
└── ex_venture/   # Application configuration
```

## Game Logic Architecture

### Command System
Commands follow a consistent pattern across multiple files:

1. Command Definition (`/lib/game/command/`)
   - Individual command modules (e.g., `whisper.ex`, `equipment.ex`)
   - Command parsing and validation
   - Command execution logic

2. Event Handlers (`/lib/game/events/`)
   - Event definitions
   - Event processing
   - Room and character events

3. Formatting (`/lib/game/format/`)
   - Message formatting
   - Color codes
   - Output templates

4. Session Management (`/lib/game/session/`)
   - Character state
   - GMCP handling
   - Session persistence

### Core Game Components

#### World Management
- `/lib/game/world/` - World state and management
- `/lib/game/zone/` - Zone definitions and loading
- `/lib/game/room/` - Room management and state
- `/lib/game/map/` - World mapping and navigation

#### Character System
- `/lib/game/character/` - Character state and management
- `/lib/game/skills/` - Skill system
- `/lib/game/stats/` - Character statistics
- `/lib/game/experience/` - Leveling and experience

#### Item System
- `/lib/game/item.ex` - Item properties and behavior
- `/lib/game/items.ex` - Item management
- `/lib/game/equipment/` - Equipment handling
- `/lib/game/shop/` - Shop and trading system

#### NPC System
- `/lib/game/npc/` - NPC behavior and state
- `/lib/game/quest/` - Quest system
- `/lib/game/socials.ex` - Social interactions

#### Environment
- `/lib/game/environment/` - Environmental effects
- `/lib/game/weather.ex` - Weather system
- `/lib/game/effect.ex` - Effect system

## Web Architecture

### Client Interface
- `/lib/web/templates/play/` - Game client interface
- `/lib/web/templates/character/` - Character management
- `/lib/web/templates/color/` - Color customization

### Admin Panel
- `/lib/web/templates/admin/` - Admin interface
- `/lib/web/controllers/admin/` - Admin controllers
- `/lib/web/views/admin/` - Admin views

### Base Components
- `/lib/web/templates/layout/` - Base layouts
- `/lib/web/templates/shared/` - Shared components

## Network Architecture

### Communication
- `/lib/networking/` - Network protocols
- `/lib/game/channel/` - Channel management
- `/lib/game/socket.ex` - Socket handling

### Integration
- `/lib/grapevine/` - Grapevine network integration
- `/lib/game/pg_notifications.ex` - Database notifications

## Data Architecture

### Core Data
- `/lib/data/` - Core data structures
- `/lib/game/config.ex` - Game configuration
- `/lib/game/caches.ex` - Caching system

### Persistence
- PostgreSQL database integration
- Ecto schemas and migrations
- Session persistence

## Testing Structure

### Command Tests
- `/test/game/command/` - Command-specific tests
- `/test/game/events/` - Event handler tests

### Integration Tests
- `/test/game/` - Game logic integration tests
- `/test/web/` - Web interface tests

### Unit Tests
- Individual module tests
- Component-specific tests

## Development Guidelines

### Command Implementation
When implementing new commands, follow this structure:
1. Create command module in `/lib/game/command/`
2. Add event handlers in `/lib/game/events/`
3. Implement formatters in `/lib/game/format/`
4. Add tests in `/test/game/command/`

### Web Component Implementation
1. Create templates in appropriate `/lib/web/templates/` directory
2. Implement controllers in `/lib/web/controllers/`
3. Add views in `/lib/web/views/`
4. Include tests in `/test/web/`

### Data Structure Implementation
1. Define schemas in `/lib/data/`
2. Create migrations in `/priv/repo/migrations/`
3. Implement changesets and validations
4. Add tests in `/test/data/`
