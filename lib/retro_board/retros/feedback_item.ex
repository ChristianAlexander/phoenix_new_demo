defmodule RetroBoard.Retros.FeedbackItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feedback_items" do
    field :column, :string
    field :content, :string
    field :author_name, :string

    belongs_to :retro, RetroBoard.Retros.Retro

    has_many :reactions, RetroBoard.Retros.Reaction

    timestamps()
  end

  @doc false
  def changeset(feedback_item, attrs) do
    feedback_item
    |> cast(attrs, [:retro_id, :column, :content, :author_name])
    |> validate_required([:retro_id, :column, :content, :author_name])
  end
end
