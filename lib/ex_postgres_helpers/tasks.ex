defmodule ExPostgresHelpers.Tasks do
  def migrate!(repo, apps) when is_list(apps) do
    temp_dir = Temp.mkdir!()

    apps
    |> Enum.map(fn app -> Application.app_dir(app, "priv/repo/migrations") end)
    |> Enum.map(fn path ->
      path
      |> File.ls!()
      |> Enum.map(fn p ->
        {p, "#{path}/#{p}"}
      end)
    end)
    |> List.flatten()
    |> Enum.map(fn {file_name, original_path} ->
      File.cp!(original_path, "#{temp_dir}/#{file_name}")
    end)

    Ecto.Migrator.run(repo, temp_dir, :up, all: true)

    File.rm_rf! temp_dir
  end
  def migrate!(repo, app) do
    path = Application.app_dir(app, "priv/repo/migrations")
    Ecto.Migrator.run(repo, path, :up, all: true)
  end 
end
