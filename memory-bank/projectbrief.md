# ExVenture Project Brief

## Project Overview
ExVenture is a text-based MMO (MUD) server written in Elixir, designed to provide a robust, feature-rich platform for running multiplayer text games.

## Core Goals
1. Provide a powerful web-based admin interface for game management
2. Maintain high reliability and resilience in game operations
3. Support multi-node deployment for scalability
4. Ensure secure player interactions
5. Deliver an integrated web client experience

## Key Requirements

### Technical Requirements
- PostgreSQL 10+
- Elixir 1.8.0+
- Erlang 21.0.5+
- Node.js 8.6+

### Functional Requirements
1. Web Admin Panel
   - Live-updating game content
   - PostgreSQL-based storage
   - No text file editing required

2. Web Client
   - Phoenix Channels integration
   - Accessible via /play endpoint

3. Cross-Game Features
   - Grapevine network support
   - Character registration
   - Cross-game channels and tells
   - OAuth login integration

4. Security Features
   - No plaintext password transmission
   - TOTP support
   - Secure session management

5. Resilience Features
   - Contained crash recovery
   - Session persistence
   - Multi-node support

## Success Criteria
1. Admin panel allows complete game management
2. Web client provides reliable game access
3. System maintains stability under load
4. Security measures prevent unauthorized access
5. Cross-game features enable player interaction
6. Multi-node deployment works seamlessly
