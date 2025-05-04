defmodule Web.Admin.NPCItemController do
  use Web.AdminController

  alias Web.Item
  alias Web.NPC
  alias Data.Repo
  import Ecto.Query
  require Logger

  def search(conn, %{"q" => query}) do
    Logger.info("Searching for items: #{query}")

    try do
      items = from(i in Data.Item,
        where: ilike(i.name, ^"%#{query}%"),
        limit: 5
      ) |> Repo.all()

      results = Enum.map(items, &%{id: &1.id, name: &1.name})
      json(conn, results)
    rescue
      e in Ecto.QueryError ->
        Logger.error("Error searching items: #{inspect(e)}")
        json(conn, %{error: "Error searching items"})
      e ->
        Logger.error("Unexpected error searching items: #{inspect(e)}")
        json(conn, %{error: "Unexpected error searching items"})
    end
  end

  def new(conn, %{"npc_id" => npc_id}) do
    npc = NPC.get(npc_id)
    changeset = NPC.new_item(npc)

    conn
    |> assign(:items, Item.all())
    |> assign(:npc, npc)
    |> assign(:changeset, changeset)
    |> render("new.html")
  end

  def create(conn, %{"npc_id" => npc_id, "npc_item" => params}) do
    npc = NPC.get(npc_id)

    case NPC.add_item(npc, params) do
      {:ok, npc_item} ->
        conn
        |> put_flash(:info, "Item added!")
        |> redirect(to: npc_path(conn, :show, npc_item.npc_id))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "There was an issue adding the item. Please try again.")
        |> assign(:items, Item.all())
        |> assign(:npc, npc)
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end

  def edit(conn, %{"id" => id}) do
    npc_item = NPC.get_item(id)
    npc = NPC.get(npc_item.npc_id)
    changeset = NPC.edit_item(npc_item)

    conn
    |> assign(:items, Item.all())
    |> assign(:npc_item, npc_item)
    |> assign(:npc, npc)
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update(conn, %{"id" => id, "npc_item" => params}) do
    case NPC.update_item(id, params) do
      {:ok, npc_item} ->
        conn
        |> put_flash(:info, "Item updated!")
        |> redirect(to: npc_path(conn, :show, npc_item.npc_id))

      {:error, changeset} ->
        npc_item = NPC.get_item(id)
        npc = NPC.get(npc_item.npc_id)

        conn
        |> put_flash(:error, "There was an issue updating the item. Please try again.")
        |> assign(:items, Item.all())
        |> assign(:npc_item, npc_item)
        |> assign(:npc, npc)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    case NPC.delete_item(id) do
      {:ok, npc_item} ->
        conn
        |> put_flash(:info, "Item removed!")
        |> redirect(to: npc_path(conn, :show, npc_item.npc_id))

      _ ->
        npc_item = NPC.get_item(id)

        conn
        |> put_flash(
          :error,
          "There was an issue deleting the item from the NPC. Please try again."
        )
        |> redirect(to: npc_path(conn, :show, npc_item.npc_id))
    end
  end
end
