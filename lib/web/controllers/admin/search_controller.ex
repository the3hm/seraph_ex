defmodule Web.Admin.SearchController do
  use Web, :controller
  alias Data.Repo
  import Ecto.Query
  require Logger
  alias Data.Item
  alias Data.Race
  alias Data.NPC
  alias Data.Quest
  alias Data.Zone
  alias Data.Skill
  alias Data.Class
  alias Data.Weather
  alias Data.User
  alias Data.Character
  alias Data.Social
  alias Data.Announcement
  alias Data.DamageType
  alias Data.Feature

  def search(conn, %{"q" => query}) do
    Logger.info("Searching for: #{query}")

    # Search across different tables
    items = search_items(query)
    races = search_races(query)
    npcs = search_npcs(query)
    quests = search_quests(query)
    zones = search_zones(query)
    skills = search_skills(query)
    classes = search_classes(query)
    weather = search_weather(query)
    users = search_users(query)
    characters = search_characters(query)
    socials = search_socials(query)
    announcements = search_announcements(query)
    damage_types = search_damage_types(query)
    features = search_features(query)

    Logger.info("Found items: #{inspect(items)}")
    Logger.info("Found races: #{inspect(races)}")
    Logger.info("Found npcs: #{inspect(npcs)}")
    Logger.info("Found quests: #{inspect(quests)}")
    Logger.info("Found zones: #{inspect(zones)}")
    Logger.info("Found skills: #{inspect(skills)}")
    Logger.info("Found classes: #{inspect(classes)}")
    Logger.info("Found weather: #{inspect(weather)}")
    Logger.info("Found users: #{inspect(users)}")
    Logger.info("Found characters: #{inspect(characters)}")
    Logger.info("Found socials: #{inspect(socials)}")
    Logger.info("Found announcements: #{inspect(announcements)}")
    Logger.info("Found damage types: #{inspect(damage_types)}")
    Logger.info("Found features: #{inspect(features)}")

    results = [
      Enum.map(items, &%{type: "Item", name: &1.name, url: Web.Router.Helpers.item_path(conn, :edit, &1.id)}),
      Enum.map(races, &%{type: "Race", name: &1.name, url: Web.Router.Helpers.race_path(conn, :edit, &1.id)}),
      Enum.map(npcs, &%{type: "NPC", name: &1.name, url: Web.Router.Helpers.npc_path(conn, :edit, &1.id)}),
      Enum.map(quests, &%{type: "Quest", name: &1.name, url: Web.Router.Helpers.quest_path(conn, :edit, &1.id)}),
      Enum.map(zones, &%{type: "Zone", name: &1.name, url: Web.Router.Helpers.zone_path(conn, :edit, &1.id)}),
      Enum.map(skills, &%{type: "Skill", name: &1.name, url: Web.Router.Helpers.skill_path(conn, :edit, &1.id)}),
      Enum.map(classes, &%{type: "Class", name: &1.name, url: Web.Router.Helpers.class_path(conn, :edit, &1.id)}),
      Enum.map(weather, &%{type: "Weather", name: &1.name, url: Web.Router.Helpers.weather_path(conn, :edit, &1.id)}),
      Enum.map(users, &%{type: "User", name: &1.name, url: Web.Router.Helpers.user_path(conn, :edit, &1.id)}),
      Enum.map(characters, &%{type: "Character", name: &1.name, url: Web.Router.Helpers.character_path(conn, :show, &1.id)}),
      Enum.map(socials, &%{type: "Social", name: &1.name, url: Web.Router.Helpers.social_path(conn, :edit, &1.id)}),
      Enum.map(announcements, &%{type: "Announcement", name: &1.title, url: Web.Router.Helpers.announcement_path(conn, :edit, &1.id)}),
      Enum.map(damage_types, &%{type: "Damage Type", name: &1.key, url: Web.Router.Helpers.damage_type_path(conn, :edit, &1.id)}),
      Enum.map(features, &%{type: "Feature", name: &1.key, url: Web.Router.Helpers.feature_path(conn, :edit, &1.id)})
    ] |> List.flatten()

    Logger.info("Final results: #{inspect(results)}")
    json(conn, results)
  end

  defp search_items(query) do
    from(i in Item,
      where: ilike(i.name, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end

  defp search_races(query) do
    from(r in Race,
      where: ilike(r.name, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end

  defp search_npcs(query) do
    from(n in NPC,
      where: ilike(n.name, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end

  defp search_quests(query) do
    from(q in Quest,
      where: ilike(q.name, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end

  defp search_zones(query) do
    from(z in Zone,
      where: ilike(z.name, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end

  defp search_skills(query) do
    from(s in Skill,
      where: ilike(s.name, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end

  defp search_classes(query) do
    from(c in Class,
      where: ilike(c.name, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end

  defp search_weather(query) do
    from(w in Weather,
      where: ilike(w.name, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end

  defp search_users(query) do
    from(u in User,
      where: ilike(u.name, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end

  defp search_characters(query) do
    from(c in Character,
      where: ilike(c.name, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end

  defp search_socials(query) do
    from(s in Social,
      where: ilike(s.name, ^"%#{query}%") or ilike(s.command, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end

  defp search_announcements(query) do
    from(a in Announcement,
      where: ilike(a.title, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end

  defp search_damage_types(query) do
    from(dt in DamageType,
      where: ilike(dt.key, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end

  defp search_features(query) do
    from(f in Feature,
      where: ilike(f.key, ^"%#{query}%"),
      limit: 5
    ) |> Repo.all()
  end
end
