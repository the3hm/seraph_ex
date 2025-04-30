# Heartbeat Mechanism in ExVenture

## Overview

The heartbeat mechanism in ExVenture is a critical component that maintains active connections, manages player states, and ensures real-time communication between the server and clients. It operates through a combination of GMCP (Generic Mud Communication Protocol) messages and internal state management.

## Core Components

### 1. Session Heartbeat
- Located in `lib/game/session/process.ex`
- Heartbeat timeout: 5 seconds (`@heartbeat_timeout 5_000`)
- Force disconnect period: 5 seconds (`@force_disconnect_period 5_000`)
- Save period: 15 seconds (`@save_period 15_000`)
- Schedules periodic heartbeats for active sessions
- Handles player state updates and notifications

### 2. GMCP Heartbeat
- Implemented in `lib/game/session/gmcp.ex`
- Sends `Core.Heartbeat` messages to clients
- Maintains client connection state
- Triggers periodic updates

### 3. Client Handling
- Client-side implementation in `assets/play/js/gmcp.js`
- Processes `Core.Heartbeat` messages
- Maintains connection state
- Handles reconnection logic

## Implementation Details

### Session Process Heartbeat
```elixir
def handle_info(:heartbeat, state = %{state: "active"}) do
  state |> GMCP.heartbeat()
  state |> Socket.nop()
  
  # Check for periodic weather updates
  new_state = try do
    Game.Weather.maybe_display_periodic_weather(state)
  rescue
    error ->
      Logger.error("Error in heartbeat weather processing", type: :session)
      state
  end

  self() |> schedule_heartbeat()
  {:noreply, new_state}
end
```

### GMCP Heartbeat
```elixir
def heartbeat(state) do
  state |> Socket.push_gmcp("Core.Heartbeat", Poison.encode!(%{}))
end
```

### Client-Side Handling
```javascript
let coreHeartbeat = (channel, data) => {
  Logger.log("Heartbeat");
}
```

## Message Flow

1. **Server Initiation**
   - Session process schedules heartbeat
   - Heartbeat interval: 5 seconds
   - Triggers GMCP message

2. **Client Reception**
   - Receives `Core.Heartbeat` message
   - Updates connection state
   - Processes any pending updates

3. **State Updates**
   - Weather updates
   - Player state synchronization
   - Connection health checks

## Error Handling

### Session Recovery
- Implements exponential backoff for reconnection
- Maximum 5 reconnection attempts
- Delay calculation: min(2^count * 100, 3000)ms
- Logs recovery attempts

### Error States
- Handles connection timeouts
- Manages session crashes
- Processes network errors
- Logs error states

## Integration Points

### 1. Weather System
- Periodic weather updates via `Game.Weather.maybe_display_periodic_weather/1`
- Protected with error handling to prevent heartbeat crashes
- Updates tracked via `last_weather_update` in session state
- Room-specific weather effects

### 2. Player State
- Health/Skill/Endurance regeneration via `Game.Session.Regen`
- Effect system integration via `Game.Session.Effects`
- Status updates through GMCP
- AFK status management with `@timeout_seconds`

### 3. Network State
- Session registry management via `Game.Session.Registry`
- Connection monitoring with process links
- Client synchronization through GMCP
- Socket health checks with NOP messages

### 4. Regen System
- Tick interval: 1 second (`@tick_wait 1000`)
- Endurance regen: 1 point per tick (`@endurance_regen 1`)
- Configurable regen rate via `Config.regen_tick_count/1`
- Stat updates pushed via GMCP vitals
- Automatic regen triggering when stats not at maximum

## Best Practices

1. **Session Management**
   - Regular heartbeat scheduling
   - Proper error handling
   - State synchronization

2. **Error Recovery**
   - Implement exponential backoff
   - Log recovery attempts
   - Handle edge cases

3. **Performance**
   - Efficient state updates
   - Minimal data transfer
   - Optimized processing

## Configuration

### Timeout Settings
```elixir
@heartbeat_timeout 5_000  # 5 seconds
@timeout_check 5000      # 5 seconds
@timeout_seconds Application.get_env(:ex_venture, :game)[:timeout_seconds]
@force_disconnect_period 5_000  # 5 seconds
@save_period 15_000  # 15 seconds
```

### Environment Variables
- `timeout_seconds`: Global timeout setting
- `report_players`: Player count reporting flag
- `world`: World startup configuration

## Monitoring

### Metrics
- Connection health
- Session state
- Error rates
- Recovery attempts

### Logging
- Heartbeat events
- Error states
- Recovery attempts
- State changes

## Gameplay Impact

### Timing Effects on Gameplay

1. **Stat Regeneration**
   - Health/Skill/Endurance points regenerate every 1 second (`@tick_wait 1000`)
   - Regeneration rate is configurable via `Config.regen_tick_count(5)`
   - Endurance regenerates at 1 point per tick (`@endurance_regen 1`)
   - Example: A player with 100 max health will recover 5 points every second by default

2. **Connection Management**
   - 5-second heartbeat interval ensures responsive gameplay (`@heartbeat_timeout 5_000`)
   - AFK timeout based on `@timeout_seconds` from environment config
   - Example: A player can briefly step away without disconnecting, but will be marked AFK after timeout

3. **State Persistence**
   - Character state saves every 15 seconds (`@save_period 15_000`)
   - Progress is preserved even during unexpected disconnections
   - Example: A player's inventory changes are saved automatically every 15 seconds

4. **Force Disconnect**
   - 5-second grace period before forced disconnection (`@force_disconnect_period 5_000`)
   - Allows time for recovery from temporary network issues
   - Example: Brief network hiccups won't immediately disconnect players

## Troubleshooting

### Common Issues and Solutions

1. **Connection Timeouts**
   - Symptoms:
     - Frequent disconnections
     - "Connection lost" messages
     - Lag spikes during gameplay
   - Solutions:
     - Check network stability
     - Verify client settings
     - Monitor system resources
     - Review `PlayerInstrumenter` metrics

2. **Stat Regeneration Issues**
   - Symptoms:
     - Stats not regenerating
     - Inconsistent regen rates
     - Missing stat updates
   - Solutions:
     - Verify client connection
     - Check for combat status
     - Monitor server logs
     - Verify regen configuration

3. **State Synchronization Problems**
   - Symptoms:
     - Missing inventory items
     - Lost progress
     - Character state mismatches
   - Solutions:
     - Wait for next save cycle
     - Check server logs
     - Verify database connection
     - Review session state

### Recovery Procedures

1. **Session Recovery**
   ```elixir
   # Server-side recovery handling
   def init([socket, player_id]) do
     send(self(), {:recover_session, player_id})
     PlayerInstrumenter.session_recovered()
     Logger.info("Session recovering (#{player_id}) - #{inspect(self())}", type: :session)
     {:ok, clean_state(socket)}
   end
   ```

2. **State Restoration**
   - Recovers player state and save data
   - Re-establishes room connections
   - Restores channel subscriptions
   - Reactivates GMCP communication
   - Resumes heartbeat and regen cycles

3. **Manual Recovery Steps**
   - Clear client cache if needed
   - Restart client connection
   - Check server logs for errors
   - Verify session registry state

### Automatic Recovery Features

1. **Connection Recovery**
   - Automatic session recovery on reconnect
   - State preservation during disconnects
   - Channel rejoin handling
   - Environment re-linking

2. **State Synchronization**
   - Character state restoration
   - Room state synchronization
   - Effect system recovery
   - Target system reset

3. **Health Monitoring**
   - Connection state verification
   - Session registry validation
   - Room presence confirmation
   - Channel subscription checks

## Debugging Steps

1. **Client-Side Debugging**
   ```javascript
   // Enable debug logging
   Logger.setLevel("debug");
   
   // Monitor heartbeat messages
   let coreHeartbeat = (channel, data) => {
     Logger.debug("Heartbeat received", { 
       timestamp: Date.now(),
       channel: channel,
       data: data 
     });
   }
   ```

2. **Server-Side Monitoring**
   ```elixir
   # Check session state
   Logger.debug("Session state", state: inspect(state))
   
   # Monitor heartbeat timing
   Logger.debug("Heartbeat interval", interval: @heartbeat_timeout)
   
   # Check PlayerInstrumenter metrics
   PlayerInstrumenter.session_started(:telnet)
   PlayerInstrumenter.session_recovered()
   ```

3. **Network Diagnostics**
   - Monitor packet loss
   - Check connection latency
   - Verify firewall settings
   - Review session monitoring logs

### Recovery Procedures

1. **Session Recovery**
   - Automatic reconnection attempts with exponential backoff
   - Backoff formula: `round(:math.pow(2, count) * 100)` milliseconds
   - Maximum 5 reconnection attempts
   - Session monitoring via `Monitor.monitor/2`
   - State preservation during recovery

2. **Data Recovery**
   - Last known state restoration
   - Save point recovery (15-second intervals)
   - Character state verification
   - Database consistency checks

3. **System Recovery**
   - Server restart procedures
   - Database consistency checks
   - Network configuration verification
   - Session monitoring system restart

### Monitoring System

1. **Session Tracking**
   - Uses `Session.Registry` for tracking active sessions
   - Monitors connection state via `Process.monitor/1`
   - Tracks session recovery attempts
   - Records session start/end times

2. **Metrics Collection**
   - Uses `PlayerInstrumenter` for:
     - Session starts (`session_started/1`)
     - Session recoveries (`session_recovered/0`)
     - Login tracking
     - Connection state changes
   - Logs session events with type: `:session`

3. **Error Reporting**
   - Detailed error logging with stacktraces
   - Session state dumps on critical errors
   - Weather processing error handling
   - Connection state transitions

4. **Health Checks**
   - Regular heartbeat verification
   - Connection state monitoring
   - AFK status tracking (`@timeout_seconds`)
   - Automatic disconnection on prolonged inactivity