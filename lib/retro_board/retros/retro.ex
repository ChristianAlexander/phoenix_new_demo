defmodule RetroBoard.Retros.Retro do
  use Ecto.Schema
  import Ecto.Changeset

  schema "retros" do
    field :code, :string
    field :title, :string

    field :columns, :map,
      default: %{"start" => "Start", "stop" => "Stop", "continue" => "Continue"}

    has_many :feedback_items, RetroBoard.Retros.FeedbackItem

    timestamps()
  end

  @doc false
  def changeset(retro, attrs) do
    retro
    |> cast(attrs, [:code, :title, :columns])
    |> validate_required([:code, :title])
    |> unique_constraint(:code)
  end
end
