defmodule Web.Admin.WeatherController do
  use Web.AdminController

  alias Web.Weather
  alias Web.Zone

  def index(conn, _params) do
    weather_types = Weather.all()
    conn |> assign(:weather_types, weather_types) |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    weather = Weather.get(id)
    zones = Zone.by_weather(id)
    conn
    |> assign(:weather, weather)
    |> assign(:zones, zones)
    |> render("show.html")
  end

  def new(conn, _params) do
    changeset = Weather.new()
    conn |> assign(:changeset, changeset) |> render("new.html")
  end

  def create(conn, %{"weather" => params}) do
    case Weather.create(params) do
      {:ok, weather} ->
        conn
        |> put_flash(:info, "Weather created!")
        |> redirect(to: weather_path(conn, :show, weather.id))

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_status(422)
        |> render("new.html")
    end
  end

  def edit(conn, %{"id" => id}) do
    weather = Weather.get(id)
    changeset = Weather.edit(weather)
    conn
    |> assign(:weather, weather)
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update(conn, %{"id" => id, "weather" => params}) do
    case Weather.update(id, params) do
      {:ok, weather} ->
        conn
        |> put_flash(:info, "Weather updated!")
        |> redirect(to: weather_path(conn, :show, weather.id))

      {:error, changeset} ->
        conn
        |> assign(:weather, Weather.get(id))
        |> assign(:changeset, changeset)
        |> put_status(422)
        |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    case Weather.delete(id) do
      {:ok, _weather} ->
        conn
        |> put_flash(:info, "Weather deleted!")
        |> redirect(to: weather_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "There was an issue deleting the weather type")
        |> redirect(to: weather_path(conn, :index))
    end
  end
end
