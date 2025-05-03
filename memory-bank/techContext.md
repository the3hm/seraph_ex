# Technical Context

## Technology Stack

### Core Technologies
- **Elixir** 1.8.0+
  - Primary development language
  - Powers game logic and server infrastructure

- **Erlang** 21.0.5+
  - Runtime environment
  - Provides OTP for distributed systems

- **PostgreSQL** 10+
  - Primary database
  - Stores all game content and configuration

- **Node.js** 8.6+
  - Asset compilation
  - Frontend development

### Web Technologies
- **Phoenix Framework**
  - Powers web interfaces
  - Handles WebSocket connections
  - Manages channels for real-time communication

- **Phoenix Channels**
  - Web client communication
  - Real-time game state updates

### Frontend Assets
- Located in `/assets` directory
- Managed with npm/yarn
- Webpack for bundling

## Editor Technology
- CKEditor 4.11.1 (free version)
- Loaded via CDN
- Used for rich text editing in forms
- No API key required
- Security warning suppressed via CSS
- Default configuration used

## Development Setup
```bash
# Initial setup
mix deps.get
mix compile

# Frontend assets
cd assets && npm install && node run build && cd ..

# Database
mix ecto.reset

# Run server
mix run --no-halt
```

## Server Configuration
- Default game port: 5555
- Web interface port: 4000
- Metrics endpoint: `/metrics`

## Testing Environment
```bash
# Database setup
MIX_ENV=test mix ecto.create
MIX_ENV=test mix ecto.migrate

# Run tests
mix test
```

## Deployment Considerations
1. **Docker Support**
   - Dockerfile provided
   - docker-compose.yml for local development
   - Production Docker configuration

2. **Multi-node Setup**
   - Cluster configuration required
   - Node discovery mechanism
   - Load balancing considerations

3. **Monitoring**
   - Prometheus metrics exposed
   - Grafana dashboards available
   - System health tracking

4. **Security**
   - Secure password handling
   - TOTP configuration
   - OAuth integration
   - Protected metrics endpoint

## External Integrations
1. **Grapevine Network**
   - Character registration
   - Cross-game chat
   - OAuth authentication

2. **Discord Integration**
   - Community chat bridge
   - Server status updates

## Development Tools
1. **Mix Tasks**
   - Database management
   - Asset compilation
   - Test running
   - Development server

2. **Code Quality**
   - Formatter configuration
   - Credo for linting
   - Travis CI integration

3. **Documentation**
   - MkDocs for documentation site
   - Inline documentation
   - API documentation generation
