defmodule Game.Weather do
  @moduledoc """
  Handle weather in zones and displaying weather messages
  """

  alias Data.Weather
  alias Data.Zone
  alias Data.Repo
  alias Game.Socket

  require Logger

  # Weather will be displayed every 5 minutes
  @weather_display_interval_minutes 5

  @doc """
  Get weather description for the current room
  """
  def description_for_room(%{zone_id: zone_id, ecology: ecology}) do
    zone_id
    |> get_zone_weather()
    |> maybe_get_description(ecology)
  end

  @doc """
  Get weather type for a zone
  """
  def get_zone_weather(zone_id) do
    Zone
    |> Repo.get(zone_id)
    |> Map.get(:weather_id)
    |> case do
      nil -> nil
      id -> Repo.get(Weather, id)
    end
  end

  @doc """
  Show weather message to a character entering a room
  """
  def maybe_display_weather(state, room) do
    case show_weather?(room) do
      true ->
        description = description_for_room(room)
        formatted_description = format_weather_message(description)
        state |> Game.Socket.echo(formatted_description)
        state

      false ->
        state
    end
  end

  @doc """
  Check if it's time to display a periodic weather update and if so, display it.
  Returns the updated state with the last_weather_update timestamp.
  """
  def maybe_display_periodic_weather(state) do
    try do
      do_maybe_display_periodic_weather(state)
    rescue
      error ->
        Logger.error(
          fn ->
            "Error processing weather update: #{inspect(error)}\n#{inspect(System.stacktrace())}"
          end,
          type: :weather
        )

        # Return original state without changes to prevent crashes
        state
    end
  end

  # Private implementation separated to enable error handling wrapper
  defp do_maybe_display_periodic_weather(state = %{save: %{room_id: room_id}}) do
    now = Timex.now()

    # Default to a time in the past if last_weather_update doesn't exist
    last_update = Map.get(state, :last_weather_update,
      Timex.shift(now, minutes: -(@weather_display_interval_minutes + 1)))

    # Check if it's been at least @weather_display_interval_minutes since the last update
    minutes_since_update = Timex.diff(now, last_update, :minutes)

    Logger.debug(
      fn ->
        "Weather check - Minutes since update: #{minutes_since_update}, Threshold: #{@weather_display_interval_minutes} minutes"
      end,
      type: :weather
    )

    if minutes_since_update >= @weather_display_interval_minutes do
      case Game.Environment.look(room_id) do
        {:ok, room} ->
          case show_weather?(room) do
            true ->
              description = description_for_room(room)
              formatted_description = format_weather_message(description)

              # First echo the message, then update the state with the timestamp
              Socket.echo(state, formatted_description)
              Map.put(state, :last_weather_update, now)

            false ->
              Map.put(state, :last_weather_update, now)
          end

        {:error, _reason} ->
          # Just update the timestamp to prevent continuous attempts
          Map.put(state, :last_weather_update, now)
      end
    else
      state
    end
  end

  defp do_maybe_display_periodic_weather(state) do
    # If there's no room_id or save, just return the state
    state
  end

  @doc """
  Format the weather description with styling
  """
  def format_weather_message(nil), do: nil
  def format_weather_message(description) do
    "{cyan}{white}#{description}{/white}{/cyan}"
  end

  defp show_weather?(room) do
    weather = get_zone_weather(room.zone_id)
    case weather do
      nil ->
        false

      weather ->
        in_valid_ecology = room.ecology in weather.valid_ecologies
        is_outdoors = room.ecology not in ["inside", "cave", "dungeon"]

        in_valid_ecology and is_outdoors
    end
  end

  defp maybe_get_description(nil, _ecology), do: nil

  defp maybe_get_description(weather, ecology) do
    Map.get(weather.ecology_descriptions, ecology, weather.description)
  end
end
