# System Patterns & Architecture

## Directory Structure
```
lib/
├── data/         # Core data structures
├── game/         # Game logic and commands
├── web/         # Web interfaces (admin, client)
├── networking/  # Network handling
└── metrics/     # System metrics
```

## Key Design Patterns

### Command Pattern
Commands are distributed across multiple files following a consistent pattern:
1. Command definition in `game/command/`
2. Event handlers in `game/events/`
3. Formatters in `game/format/`
4. Tests in `test/game/command/`

### Web Architecture
- Phoenix-based web interface
- Separate views for:
  - Admin panel (`/admin`)
  - Web client (`/play`)
  - Character creation
  - Base page
  - Color customization

### Admin Panel Structure
- Controllers use `Web.AdminController` to enforce authentication
- Admin layout with separate navigation sidebar
- Access control through plugs in AdminController
- Tab selection helpers for highlighting active section

### Routing Patterns
- Namespaced routes for admin area (`/admin/*`)
- Direct import of path helpers (e.g., `weather_path` not prefixed with `Routes.admin_`)
- Admin panel uses `dashboard_path` for Home links
- RESTful resource routing for game entities

### Data Management
- PostgreSQL for persistent storage
- Live updates on content changes
- No file-based configuration

### Weather System
- Weather types with global descriptions
- Ecology-specific descriptions
- Zone-to-weather associations
- Dynamic weather display based on room ecology

### Session Management
- Phoenix Channels for web client communication
- Secure session handling
- TOTP support
- No plaintext password transmission

### Resilience Patterns
1. Process Isolation
   - Crashes contained to specific rooms
   - Clean process restart mechanisms
   - Session persistence across restarts

2. Multi-Node Support
   - Distributed world across cluster
   - Node failure tolerance
   - Cluster-wide communication

### Testing Strategy
- Comprehensive test suite
- Command-specific test files
- Integration tests for web interfaces
- Cluster behavior testing

## Editor Pattern
- Rich text editing is handled by CKEditor 4.11.1
- Editor is initialized on form textareas using `CKEDITOR.replace()`
- Initialization is wrapped in `DOMContentLoaded` event listener
- Security warnings are suppressed via CSS
- Implementation is kept simple with default configuration
- Used in announcement and note forms for content editing

## Core Architectural Principles
1. **Modularity**: Clear separation of concerns across directories
2. **Resilience**: Fault isolation and recovery
3. **Security**: Secure authentication and communication
4. **Scalability**: Multi-node support built-in
5. **Maintainability**: Web-based administration
6. **Consistency**: Predictable naming and routing patterns
