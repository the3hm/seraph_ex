defmodule Data.Weather do
  @moduledoc """
  Weather Type Schema
  """

  use Data.Schema

  alias Data.Room
  alias Data.Zone

  schema "weather_types" do
    field(:name, :string)
    field(:description, :string)
    field(:valid_ecologies, {:array, :string})
    field(:ecology_descriptions, :map)
    field(:effects, {:array, :integer})

    has_many(:zones, Zone)

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name, :description, :valid_ecologies, :ecology_descriptions, :effects])
    |> ensure(:ecology_descriptions, %{})
    |> ensure(:effects, [])
    |> validate_required([:name, :description, :valid_ecologies])
    |> validate_change(:valid_ecologies, &validate_ecologies/2)
    |> validate_change(:ecology_descriptions, &validate_ecology_descriptions/2)
    |> unique_constraint(:name)
  end

  @doc """
  Get description for a specific ecology, falling back to default description
  """
  def description_for_ecology(weather, ecology) do
    Map.get(weather.ecology_descriptions, ecology, weather.description)
  end

  defp validate_ecology_descriptions(:ecology_descriptions, descriptions) do
    descriptions
    |> Enum.reduce([], fn {ecology, _description}, errors ->
      case ecology in Room.ecologies() do
        true -> errors
        false -> [{:ecology_descriptions, "invalid ecology #{ecology}"}] ++ errors
      end
    end)
  end

  defp validate_ecologies(:valid_ecologies, ecologies) do
    Enum.reduce(ecologies, [], fn ecology, errors ->
      case ecology in Room.ecologies() do
        true -> errors
        false -> [{:valid_ecologies, "invalid ecology #{ecology}"}] ++ errors
      end
    end)
  end
end
