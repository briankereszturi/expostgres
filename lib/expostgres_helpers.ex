defmodule ExpostgresHelpers do
  import Ecto.Query

  require Logger

  def get_rows(repo, query) do
    try do
      {:ok, repo.all(query)}
    rescue
      e ->
        Logger.error "Query failure: #{inspect e}"
        {:error, :internal_server_error}
    end
  end

  def get_all_nil(repo, model, key) do
    query = from r in model,
      where: is_nil(field(r, ^key))

    with {:ok, rows} <- get_rows(repo, query),
      do: {:ok, rows}
  end

  def get_by(repo, model, key, value, associations \\ []) do
    query = from r in model,
      where: field(r, ^key) == ^value,
      preload: ^associations

    with {:ok, rows} <- get_rows(repo, query),
         [first | _] <- rows do
      {:ok, first}
    else
      [] -> {:error, :not_found}
      e ->
        Logger.error "Query failure: #{inspect e}"
        e
    end
  end

  def get_by_id(repo, model, id, associations \\ []),
    do: get_by(repo, model, :id, id, associations)

  def get_all(repo, model),
    do: get_rows(repo, from model)

  def delete(repo, %{__struct__: _}=struct) do
    repo.delete(struct)
    :ok
  end

  def delete_query(repo, query) do
    query |> repo.delete_all()
    :ok
  end

  def delete_all(repo, model) do
    {_numDeleted, _returned} = repo.delete_all(from model)
    :ok
  end
end
