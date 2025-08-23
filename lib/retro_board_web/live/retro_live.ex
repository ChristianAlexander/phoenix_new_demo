defmodule RetroBoardWeb.RetroLive do
  use RetroBoardWeb, :live_view

  alias RetroBoard.Retros
  alias Phoenix.PubSub

  @impl true
  def mount(params, _session, socket) do
    case Map.get(params, "code") do
      nil ->
        # Landing page - show create/join forms
        user_session_id = get_connect_params(socket)["_csrf_token"] || "anonymous"

        {:ok, assign_landing_page(socket, user_session_id)}

      code ->
        user_session_id = get_connect_params(socket)["_csrf_token"] || "anonymous"

        # Join existing retro by code
        case Retros.get_retro_by_code_with_feedback(code) do
          nil ->
            {:ok,
             socket
             |> put_flash(:error, "Retro not found with code: #{String.upcase(code)}")
             |> assign_landing_page(user_session_id)}

          retro ->
            if connected?(socket) do
              PubSub.subscribe(RetroBoard.PubSub, "retro:#{retro.id}")
            end

            {:ok, assign_retro_board(socket, retro, user_session_id)}
        end
    end
  end

  @impl true
  def handle_event("toggle_reaction", %{"item_id" => item_id, "emoji" => emoji}, socket) do
    user_session_id = get_connect_params(socket)["_csrf_token"] || "anonymous"

    case Retros.toggle_reaction(String.to_integer(item_id), user_session_id, emoji) do
      {:ok, _reaction} ->
        # Broadcast reaction change to all users in this retro
        PubSub.broadcast(
          RetroBoard.PubSub,
          "retro:#{socket.assigns.retro.id}",
          {:reaction_changed, String.to_integer(item_id)}
        )

        {:noreply, socket}

      {:error, _changeset} ->
        # Reaction was removed (delete operation)
        PubSub.broadcast(
          RetroBoard.PubSub,
          "retro:#{socket.assigns.retro.id}",
          {:reaction_changed, String.to_integer(item_id)}
        )

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("create_retro", %{"retro" => retro_params}, socket) do
    case Retros.create_retro(retro_params) do
      {:ok, retro} ->
        if connected?(socket) do
          PubSub.subscribe(RetroBoard.PubSub, "retro:#{retro.id}")
        end

        {:noreply,
         socket
         |> put_flash(:info, "Retro created! Share code: #{retro.code}")
         |> push_navigate(to: ~p"/retro/#{retro.code}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :create_form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("join_retro", %{"join" => %{"code" => code}}, socket) do
    case Retros.get_retro_by_code(code) do
      nil ->
        {:noreply, put_flash(socket, :error, "Retro not found with code: #{String.upcase(code)}")}

      retro ->
        {:noreply, push_navigate(socket, to: ~p"/retro/#{retro.code}")}
    end
  end

  @impl true
  def handle_event("set_user_name", %{"user" => %{"name" => name}}, socket) do
    {:noreply, assign(socket, :user_name, name)}
  end

  @impl true
  def handle_event("add_feedback", %{"feedback" => feedback_params}, socket) do
    %{"column" => column, "content" => content} = feedback_params
    retro = socket.assigns.retro
    user_name = socket.assigns.user_name

    case Retros.add_feedback_item(retro.id, column, content, user_name) do
      {:ok, feedback_item} ->
        # Broadcast to all users in this retro
        PubSub.broadcast(
          RetroBoard.PubSub,
          "retro:#{retro.id}",
          {:new_feedback, feedback_item}
        )

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to add feedback")}
    end
  end

  @impl true
  def handle_info({:reaction_changed, _item_id}, socket) do
    retro = Retros.get_retro_by_code_with_feedback(socket.assigns.retro.code)
    {:noreply, assign(socket, :retro, retro)}
  end

  @impl true
  def handle_info({:new_feedback, _feedback_item}, socket) do
    retro = Retros.get_retro_by_code_with_feedback(socket.assigns.retro.code)
    {:noreply, assign(socket, :retro, retro)}
  end

  defp assign_landing_page(socket, user_session_id) do
    create_changeset = Retros.Retro.changeset(%Retros.Retro{}, %{})

    socket
    |> assign(:page_mode, :landing)
    |> assign(:user_session_id, user_session_id)
    |> assign(:create_form, to_form(create_changeset))
    |> assign(:join_form, to_form(%{}, as: :join))
  end

  defp assign_retro_board(socket, retro, user_session_id) do
    socket
    |> assign(:page_mode, :board)
    |> assign(:user_session_id, user_session_id)
    |> assign(:retro, retro)
    |> assign(:user_name, nil)
    |> assign(:user_form, to_form(%{}, as: :user))
    |> assign(:feedback_forms, build_feedback_forms(retro.columns))
  end

  defp build_feedback_forms(columns) do
    for {column_key, _column_name} <- columns, into: %{} do
      {column_key, to_form(%{}, as: :feedback)}
    end
  end

  # Helper functions for column styling
  defp column_bg_class("start"), do: "bg-green-50"
  defp column_bg_class("stop"), do: "bg-red-50"
  defp column_bg_class("continue"), do: "bg-blue-50"
  defp column_bg_class(_), do: "bg-gray-50"

  defp column_text_class("start"), do: "text-green-800"
  defp column_text_class("stop"), do: "text-red-800"
  defp column_text_class("continue"), do: "text-blue-800"
  defp column_text_class(_), do: "text-gray-800"

  defp column_border_class("start"), do: "border-green-200"
  defp column_border_class("stop"), do: "border-red-200"
  defp column_border_class("continue"), do: "border-blue-200"
  defp column_border_class(_), do: "border-gray-200"

  defp column_icon("start"), do: "🟢"
  defp column_icon("stop"), do: "🔴"
  defp column_icon("continue"), do: "🔵"
  defp column_icon(_), do: "⚪"
end
