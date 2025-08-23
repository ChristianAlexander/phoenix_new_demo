defmodule RetroBoard.Retros.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reactions" do
    field :user_session_id, :string
    field :emoji, :string

    belongs_to :feedback_item, RetroBoard.Retros.FeedbackItem

    timestamps()
  end

  @doc false
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:feedback_item_id, :user_session_id, :emoji])
    |> validate_required([:feedback_item_id, :user_session_id, :emoji])
    |> validate_inclusion(:emoji, ["👍", "❤️", "💡", "🚀", "😅"])
    |> unique_constraint([:feedback_item_id, :user_session_id, :emoji])
  end
end
