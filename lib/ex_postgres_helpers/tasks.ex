defmodule ExPostgresHelpers.Tasks do
  def migrate(repo, app) do
    path = Application.app_dir(app, "priv/repo/migrations")
    Ecto.Migrator.run(repo, path, :up, all: true)
  end 
end
