defmodule RetroBoardWeb.PageController do
  use RetroBoardWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
