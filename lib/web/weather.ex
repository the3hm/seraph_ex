defmodule Web.Weather do
  @moduledoc """
  Weather context
  """

  import Ecto.Query

  alias Data.Weather
  alias Data.Repo
  alias Web.Filter

  @doc """
  Get all weather types
  """
  def all() do
    Weather
    |> order_by([w], w.name)
    |> Repo.all()
  end

  @doc """
  Get a weather type
  """
  def get(id) do
    Weather
    |> Repo.get(id)
  end

  @doc """
  Get a changeset for a new weather type
  """
  def new(), do: %Weather{} |> Weather.changeset(%{})

  @doc """
  Get a changeset for editing a weather type
  """
  def edit(weather), do: weather |> Weather.changeset(%{})

  @doc """
  Create a weather type
  """
  def create(params) do
    %Weather{}
    |> Weather.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Update a weather type
  """
  def update(id, params) do
    id
    |> get()
    |> Weather.changeset(params)
    |> Repo.update()
  end

  @doc """
  Delete a weather type
  """
  def delete(id) do
    id
    |> get()
    |> Repo.delete()
  end

  @doc """
  Get the description for a specific ecology
  """
  def description_for_ecology(weather, ecology) do
    Weather.description_for_ecology(weather, ecology)
  end

  @doc """
  Filter weather types by ecology
  """
  def filter_by_ecology(query, ecology) do
    query
    |> where([w], ^ecology in w.valid_ecologies)
  end

  @doc """
  Get weather types for select boxes
  """
  def select_options() do
    Weather
    |> order_by([w], w.name)
    |> Repo.all()
    |> Enum.map(&{&1.name, &1.id})
  end
end
