defmodule SubjectManagerWeb.SubjectLive.ShowTest do
  use SubjectManagerWeb.ConnCase

  import Phoenix.LiveViewTest
  import SubjectManager.SubjectsFixtures

  describe "Show page" do
    test "displays subject details", %{conn: conn} do
      subject =
        subject_fixture(
          name: "Lionel Messi",
          team: "Inter Miami CF",
          position: :forward,
          bio: "One of the greatest players of all time."
        )

      {:ok, _view, html} = live(conn, ~p"/subjects/#{subject.id}")

      assert html =~ "Lionel Messi"
      assert html =~ "Inter Miami CF"
      assert html =~ "forward"
      assert html =~ "One of the greatest players of all time."
    end

    test "displays subject image", %{conn: conn} do
      subject = subject_fixture(image_path: "/images/test-player.jpg")

      {:ok, _view, html} = live(conn, ~p"/subjects/#{subject.id}")

      assert html =~ subject.image_path
      assert html =~ ~s(<img)
    end

    test "has back to subjects link", %{conn: conn} do
      subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/subjects/#{subject.id}")

      assert view |> element("a", "Back to Subjects") |> has_element?()
    end

    test "back link navigates to home page", %{conn: conn} do
      subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/subjects/#{subject.id}")

      {:ok, _view, html} =
        view |> element("a", "Back to Subjects") |> render_click() |> follow_redirect(conn)

      # Should be on the index page
      assert html =~ subject.name
    end

    test "uses subject-show CSS class", %{conn: conn} do
      subject = subject_fixture()

      {:ok, _view, html} = live(conn, ~p"/subjects/#{subject.id}")

      assert html =~ ~s(class="subject-show")
    end

    test "displays position badge", %{conn: conn} do
      subject = subject_fixture(position: :goalkeeper)

      {:ok, _view, html} = live(conn, ~p"/subjects/#{subject.id}")

      assert html =~ "goalkeeper"
      # Badge component should be present
      assert html =~ ~r/class=".*border.*"/
    end

    test "page title includes subject name", %{conn: conn} do
      subject = subject_fixture(name: "Test Player")

      {:ok, view, _html} = live(conn, ~p"/subjects/#{subject.id}")

      assert page_title(view) =~ "Test Player"
    end
  end

  describe "Show page errors" do
    test "returns 404 for non-existent subject", %{conn: conn} do
      assert_error_sent 404, fn ->
        live(conn, ~p"/subjects/99999")
      end
    end
  end

  describe "Show page with different positions" do
    test "displays forward position correctly", %{conn: conn} do
      subject = subject_fixture(position: :forward)

      {:ok, _view, html} = live(conn, ~p"/subjects/#{subject.id}")

      assert html =~ "forward"
    end

    test "displays midfielder position correctly", %{conn: conn} do
      subject = subject_fixture(position: :midfielder)

      {:ok, _view, html} = live(conn, ~p"/subjects/#{subject.id}")

      assert html =~ "midfielder"
    end

    test "displays winger position correctly", %{conn: conn} do
      subject = subject_fixture(position: :winger)

      {:ok, _view, html} = live(conn, ~p"/subjects/#{subject.id}")

      assert html =~ "winger"
    end

    test "displays defender position correctly", %{conn: conn} do
      subject = subject_fixture(position: :defender)

      {:ok, _view, html} = live(conn, ~p"/subjects/#{subject.id}")

      assert html =~ "defender"
    end

    test "displays goalkeeper position correctly", %{conn: conn} do
      subject = subject_fixture(position: :goalkeeper)

      {:ok, _view, html} = live(conn, ~p"/subjects/#{subject.id}")

      assert html =~ "goalkeeper"
    end
  end

  describe "Show page with long content" do
    test "displays long biography without truncation", %{conn: conn} do
      long_bio = String.duplicate("This is a very long biography. ", 50)
      subject = subject_fixture(bio: long_bio)

      {:ok, _view, html} = live(conn, ~p"/subjects/#{subject.id}")

      assert html =~ long_bio
    end

    test "displays long team name correctly", %{conn: conn} do
      long_team_name = "Football Club with a Very Long Name That Should Still Display Correctly"
      subject = subject_fixture(team: long_team_name)

      {:ok, _view, html} = live(conn, ~p"/subjects/#{subject.id}")

      assert html =~ long_team_name
    end
  end
end
