defmodule Data.NPCItem do
  @moduledoc """
  NPC Item Schema
  """

  use Data.Schema

  alias Data.Item
  alias Data.NPC

  schema "npc_items" do
    field(:drop_rate, :float, default: 10.0)

    belongs_to(:npc, NPC)
    belongs_to(:item, Item)

    timestamps()
  end

  def changeset(struct, params) do
    # Convert string drop_rate to float if it's a string
    params = case params do
      %{"drop_rate" => drop_rate} when is_binary(drop_rate) ->
        # Handle strings that start with a decimal point by prepending a "0"
        drop_rate = if String.starts_with?(drop_rate, "."), do: "0#{drop_rate}", else: drop_rate
        case Float.parse(drop_rate) do
          {float_val, _} -> %{params | "drop_rate" => float_val}
          :error -> params
        end
      _ -> params
    end

    struct
    |> cast(params, [:npc_id, :item_id, :drop_rate])
    |> validate_required([:npc_id, :item_id, :drop_rate])
    |> validate_number(:drop_rate, greater_than_or_equal_to: 0.0001, less_than_or_equal_to: 100.0)
    |> foreign_key_constraint(:npc_id)
    |> foreign_key_constraint(:item_id)
  end

  def update_changeset(struct, params) do
    # Convert string drop_rate to float if it's a string
    params = case params do
      %{"drop_rate" => drop_rate} when is_binary(drop_rate) ->
        # Handle strings that start with a decimal point by prepending a "0"
        drop_rate = if String.starts_with?(drop_rate, "."), do: "0#{drop_rate}", else: drop_rate
        case Float.parse(drop_rate) do
          {float_val, _} -> %{params | "drop_rate" => float_val}
          :error -> params
        end
      _ -> params
    end

    struct
    |> cast(params, [:drop_rate])
    |> validate_required([:drop_rate])
    |> validate_number(:drop_rate, greater_than_or_equal_to: 0.0001, less_than_or_equal_to: 100.0)
  end
end
