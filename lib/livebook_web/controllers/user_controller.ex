defmodule LivebookWeb.UserController do
  use LivebookWeb, :controller

  def logout(conn, _params) do
    if get_session(conn, :user_id) do
      if get_session(conn, :teams_logout) do
        do_logout(conn)
      else
        if Livebook.Config.logout_enabled?() do
          do_zta_logout(conn)
        else
          do_logout(conn)
        end
      end
    else
      redirect(conn, to: ~p"/")
    end
  end

  defp do_logout(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
    |> render("logout.html")
  end

  defp do_zta_logout(conn) do
    {_type, module, _key} = Livebook.Config.identity_provider()

    case module.logout(LivebookWeb.ZTA, conn) do
      :ok -> do_logout(conn)
      {:ok, url} -> redirect(conn, external: url)
      {:error, reason} -> conn |> redirect(to: ~p"/") |> put_flash(:error, reason)
    end
  end
end
