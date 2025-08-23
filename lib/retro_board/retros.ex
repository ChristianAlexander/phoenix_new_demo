defmodule RetroBoard.Retros do
  @moduledoc """
  The Retros context.
  """

  import Ecto.Query, warn: false
  alias RetroBoard.Repo

  alias RetroBoard.Retros.{Retro, FeedbackItem, Reaction}

  @doc """
  Creates a retro with a unique random code.
  """
  def create_retro(attrs \\ %{}) do
    code = generate_unique_code()

    attrs = Map.put(attrs, "code", code)

    %Retro{}
    |> Retro.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a retro by its unique code.
  """
  def get_retro_by_code(code) do
    Repo.get_by(Retro, code: String.upcase(code))
  end

  @doc """
  Gets a retro by its unique code and preloads feedback items.
  """
  def get_retro_by_code_with_feedback(code) do
    from(r in Retro,
      where: r.code == ^String.upcase(code),
      preload: [:feedback_items]
    )
    |> Repo.one()
  end

  @doc """
  Adds a feedback item to a retro.
  """
  def add_feedback_item(retro_id, column, content, author_name) do
    %FeedbackItem{}
    |> FeedbackItem.changeset(%{
      retro_id: retro_id,
      column: column,
      content: content,
      author_name: author_name
    })
    |> Repo.insert()
  end

  @doc """
  Lists all feedback items for a retro, grouped by column.
  """
  def list_feedback_items_by_retro(retro_id) do
    from(f in FeedbackItem,
      where: f.retro_id == ^retro_id,
      order_by: [desc: f.inserted_at]
    )
    |> Repo.all()
    |> Enum.group_by(& &1.column)
  end

  defp generate_unique_code do
    code = generate_code()

    case get_retro_by_code(code) do
      nil -> code
      _retro -> generate_unique_code()
    end
  end

  @doc """
  Toggles a reaction for a feedback item by a user.
  """
  def toggle_reaction(feedback_item_id, user_session_id, emoji) do
    case Repo.get_by(Reaction,
           feedback_item_id: feedback_item_id,
           user_session_id: user_session_id,
           emoji: emoji
         ) do
      nil ->
        # Create new reaction
        %Reaction{}
        |> Reaction.changeset(%{
          feedback_item_id: feedback_item_id,
          user_session_id: user_session_id,
          emoji: emoji
        })
        |> Repo.insert()

      reaction ->
        # Delete existing reaction
        Repo.delete(reaction)
    end
  end

  @doc """
  Gets reaction counts for a feedback item.
  """
  def get_reaction_counts(feedback_item_id) do
    from(r in Reaction,
      where: r.feedback_item_id == ^feedback_item_id,
      group_by: r.emoji,
      select: {r.emoji, count(r.id)}
    )
    |> Repo.all()
    |> Enum.into(%{})
  end

  @doc """
  Gets user reactions for a feedback item.
  """
  def get_user_reactions(feedback_item_id, user_session_id) do
    from(r in Reaction,
      where: r.feedback_item_id == ^feedback_item_id and r.user_session_id == ^user_session_id,
      select: r.emoji
    )
    |> Repo.all()
  end

  defp generate_code do
    # Generate a 6-character alphanumeric code
    :crypto.strong_rand_bytes(3)
    |> Base.encode16()
    |> String.upcase()
  end
end
