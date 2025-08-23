defmodule RetroBoard.Repo.Migrations.CreateRetrosAndFeedbackItems do
  use Ecto.Migration

  def change do
    create table(:retros) do
      add :code, :string, null: false
      add :title, :string, null: false

      add :columns, :map,
        default: %{"start" => "Start", "stop" => "Stop", "continue" => "Continue"}

      timestamps()
    end

    create unique_index(:retros, [:code])

    create table(:feedback_items) do
      add :retro_id, references(:retros, on_delete: :delete_all), null: false
      add :column, :string, null: false
      add :content, :text, null: false
      add :author_name, :string, null: false

      timestamps()
    end

    create index(:feedback_items, [:retro_id])
    create index(:feedback_items, [:retro_id, :column])
  end
end
