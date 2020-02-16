defmodule RumblWeb.VideoControllerTest do
  use RumblWeb.ConnCase, async: true

  alias Rumbl.Multimedia

  @create_attrs %{description: "desc", title: "title", url: "http://local"}
  @invalid_attrs %{title: "invalid"}

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.video_path(conn, :new)),
        get(conn, Routes.video_path(conn, :index)),
        get(conn, Routes.video_path(conn, :show, "123")),
        get(conn, Routes.video_path(conn, :edit, "123")),
        put(conn, Routes.video_path(conn, :update, "123", %{})),
        post(conn, Routes.video_path(conn, :create, %{})),
        delete(conn, Routes.video_path(conn, :delete, "123"))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  test "authorizes actions against access by others users", %{conn: conn} do
    owner = user_fixture()
    video = video_fixture(owner, @create_attrs)
    non_owner = user_fixture(username: "sneaky")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      get(conn, Routes.video_path(conn, :show, video))
    end

    assert_error_sent :not_found, fn ->
      get(conn, Routes.video_path(conn, :edit, video))
    end

    assert_error_sent :not_found, fn ->
      put(conn, Routes.video_path(conn, :update, video), video: @create_attrs)
    end

    assert_error_sent :not_found, fn ->
      delete(conn, Routes.video_path(conn, :delete, video))
    end
  end

  describe "/videos with a logged-in user" do
    defp video_count, do: Enum.count(Multimedia.list_videos())

    setup %{conn: conn, login_as: username} do
      user = user_fixture(username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "johndoe"
    test "lists all user's videos on index", %{conn: conn, user: user} do
      another_user = user_fixture(username: "other")
      user_video = video_fixture(user, title: "funny_cats")
      other_video = video_fixture(another_user, title: "another video")
      conn = get(conn, Routes.video_path(conn, :index))

      assert html_response(conn, 200) =~ ~r/Listing Videos/
      assert String.contains?(conn.resp_body, user_video.title)
      refute String.contains?(conn.resp_body, other_video.title)
    end

    @tag login_as: "johndoe"
    test "creates user videos and redirects", %{conn: conn, user: user} do
      create_conn = post(conn, Routes.video_path(conn, :create), video: @create_attrs)

      assert %{id: id} = redirected_params(create_conn)
      assert redirected_to(create_conn) == Routes.video_path(create_conn, :show, id)

      conn = get(conn, Routes.video_path(conn, :show, id))

      assert html_response(conn, 200) =~ "Show Video"
      assert Multimedia.get_video!(id).user_id == user.id
    end

    @tag login_as: "johndoe"
    test "does not create video, renders errors when invalid", %{conn: conn} do
      count_before = video_count()
      conn = post(conn, Routes.video_path(conn, :create), video: @invalid_attrs)
      assert html_response(conn, 200) =~ "check the errors"
      assert video_count() == count_before
    end
  end
end
