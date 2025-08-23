defmodule RetroBoard.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:reactions) do
      add :feedback_item_id, references(:feedback_items, on_delete: :delete_all), null: false
      add :user_session_id, :string, null: false
      add :emoji, :string, null: false

      timestamps()
    end

    create index(:reactions, [:feedback_item_id])
    create index(:reactions, [:feedback_item_id, :user_session_id])
    create unique_index(:reactions, [:feedback_item_id, :user_session_id, :emoji])
  end
end
