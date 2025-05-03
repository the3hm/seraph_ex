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

    Logger.info("Found items: #{inspect(items)}")
    Logger.info("Found races: #{inspect(races)}")
    Logger.info("Found npcs: #{inspect(npcs)}")
    Logger.info("Found quests: #{inspect(quests)}")
    Logger.info("Found zones: #{inspect(zones)}")
    Logger.info("Found skills: #{inspect(skills)}")
    Logger.info("Found classes: #{inspect(classes)}")

    results = [
      Enum.map(items, &%{type: "Item", name: &1.name, url: Web.Router.Helpers.item_path(conn, :edit, &1.id)}),
      Enum.map(races, &%{type: "Race", name: &1.name, url: Web.Router.Helpers.race_path(conn, :edit, &1.id)}),
      Enum.map(npcs, &%{type: "NPC", name: &1.name, url: Web.Router.Helpers.npc_path(conn, :edit, &1.id)}),
      Enum.map(quests, &%{type: "Quest", name: &1.name, url: Web.Router.Helpers.quest_path(conn, :edit, &1.id)}),
      Enum.map(zones, &%{type: "Zone", name: &1.name, url: Web.Router.Helpers.zone_path(conn, :edit, &1.id)}),
      Enum.map(skills, &%{type: "Skill", name: &1.name, url: Web.Router.Helpers.skill_path(conn, :edit, &1.id)}),
      Enum.map(classes, &%{type: "Class", name: &1.name, url: Web.Router.Helpers.class_path(conn, :edit, &1.id)})
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
end
