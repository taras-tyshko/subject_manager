defmodule SubjectManagerWeb.SubjectLive.IndexTest do
  use SubjectManagerWeb.ConnCase

  import Phoenix.LiveViewTest
  import SubjectManager.SubjectsFixtures

  describe "Index page" do
    test "displays list of subjects", %{conn: conn} do
      _subject1 = subject_fixture(name: "Lionel Messi")
      _subject2 = subject_fixture(name: "Luis Suárez")

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Lionel Messi"
      assert html =~ "Luis Suárez"
    end

    test "displays empty message when no subjects match filters", %{conn: conn} do
      _subject = subject_fixture(name: "Lionel Messi")

      {:ok, view, _html} = live(conn, ~p"/")

      html = view |> element("#filter-form") |> render_change(%{q: "Nonexistent Player"})

      assert html =~ "No subjects found"
    end

    test "each subject card has correct information", %{conn: conn} do
      subject = subject_fixture(name: "Lionel Messi", team: "Inter Miami CF", position: :forward)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ subject.name
      assert html =~ subject.team
      assert html =~ "forward"
    end

    test "subject cards link to detail page", %{conn: conn} do
      subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/")

      assert view |> element("a[href='/subjects/#{subject.id}']") |> has_element?()
    end
  end

  describe "Search filter" do
    setup do
      messi = subject_fixture(name: "Lionel Messi")
      suarez = subject_fixture(name: "Luis Suárez")
      lo_celso = subject_fixture(name: "Giovani Lo Celso")

      %{messi: messi, suarez: suarez, lo_celso: lo_celso}
    end

    test "filters subjects by name in real-time", %{conn: conn, messi: messi} do
      {:ok, view, _html} = live(conn, ~p"/")

      html = view |> element("#filter-form") |> render_change(%{q: "Messi"})

      assert html =~ messi.name
      refute html =~ "Luis Suárez"
      refute html =~ "Giovani Lo Celso"
    end

    test "search is case insensitive", %{conn: conn, messi: messi} do
      {:ok, view, _html} = live(conn, ~p"/")

      html = view |> element("#filter-form") |> render_change(%{q: "messi"})

      assert html =~ messi.name
    end

    test "partial name match works", %{conn: conn, suarez: suarez} do
      {:ok, view, _html} = live(conn, ~p"/")

      html = view |> element("#filter-form") |> render_change(%{q: "Suá"})

      assert html =~ suarez.name
    end

    test "filters and updates view when searching", %{conn: conn, messi: messi} do
      {:ok, view, _html} = live(conn, ~p"/")

      html = view |> element("#filter-form") |> render_change(%{q: "Messi"})

      assert html =~ messi.name
    end
  end

  describe "Position filter" do
    setup do
      forward = subject_fixture(position: :forward, name: "Forward Player")
      midfielder = subject_fixture(position: :midfielder, name: "Midfielder Player")
      goalkeeper = subject_fixture(position: :goalkeeper, name: "Goalkeeper Player")

      %{forward: forward, midfielder: midfielder, goalkeeper: goalkeeper}
    end

    test "filters subjects by position", %{conn: conn, forward: forward} do
      {:ok, view, _html} = live(conn, ~p"/")

      html = view |> element("#filter-form") |> render_change(%{position: "forward"})

      assert html =~ forward.name
      refute html =~ "Midfielder Player"
      refute html =~ "Goalkeeper Player"
    end

    test "filters and updates view when selecting position", %{conn: conn, forward: forward} do
      {:ok, view, _html} = live(conn, ~p"/")

      html = view |> element("#filter-form") |> render_change(%{position: "forward"})

      assert html =~ forward.name
    end

    test "shows all positions when no filter selected", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Forward Player"
      assert html =~ "Midfielder Player"
      assert html =~ "Goalkeeper Player"
    end
  end

  describe "Sorting" do
    setup do
      _charlie = subject_fixture(name: "Charlie", team: "Zebra FC")
      _alice = subject_fixture(name: "Alice", team: "Alpha FC")
      _bob = subject_fixture(name: "Bob", team: "Beta FC")

      :ok
    end

    test "sorts subjects by name ascending", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("#filter-form") |> render_change(%{sort_by: "name"})

      html = render(view)
      alice_pos = :binary.match(html, "Alice") |> elem(0)
      bob_pos = :binary.match(html, "Bob") |> elem(0)
      charlie_pos = :binary.match(html, "Charlie") |> elem(0)

      assert alice_pos < bob_pos
      assert bob_pos < charlie_pos
    end

    test "toggles sort order from ascending to descending", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Set sort by name (defaults to ASC)
      view |> element("#filter-form") |> render_change(%{sort_by: "name"})

      # Toggle to DESC
      html = view |> element("button.sort-order-toggle") |> render_click()

      assert html =~ "▼ DESC"
    end

    test "sorts by team", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("#filter-form") |> render_change(%{sort_by: "team"})

      html = render(view)
      alpha_pos = :binary.match(html, "Alpha FC") |> elem(0)
      beta_pos = :binary.match(html, "Beta FC") |> elem(0)
      zebra_pos = :binary.match(html, "Zebra FC") |> elem(0)

      assert alpha_pos < beta_pos
      assert beta_pos < zebra_pos
    end

    test "applies selected sort field", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html = view |> element("#filter-form") |> render_change(%{sort_by: "position"})

      # Sort toggle button should appear when sort is selected
      assert html =~ "sort-order-toggle"
    end

    test "toggles to descending when clicking same field", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Set sort by name (defaults to ASC)
      view |> element("#filter-form") |> render_change(%{sort_by: "name"})
      assert render(view) =~ "▲ ASC"

      # Toggle to DESC on same field
      html = view |> element("button.sort-order-toggle") |> render_click()
      assert html =~ "▼ DESC"

      # Toggle back to ASC
      html = view |> element("button.sort-order-toggle") |> render_click()
      assert html =~ "▲ ASC"
    end

    test "defaults to ascending when switching to different field", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Sort by name DESC
      view |> element("#filter-form") |> render_change(%{sort_by: "name", sort_order: "desc"})
      assert render(view) =~ "▼ DESC"

      # Switch to different field (team) - should default to ASC
      html = view |> element("button.sort-order-toggle") |> render_click(%{"field" => "team"})
      assert html =~ "▲ ASC"
    end
  end

  describe "Empty state" do
    test "shows no results message when no subjects match filter", %{conn: conn} do
      subject_fixture(name: "Test Player")

      {:ok, _view, html} = live(conn, ~p"/?q=NonexistentPlayer")

      assert html =~ "No subjects found"
    end
  end

  describe "Combined filters" do
    setup do
      _messi = subject_fixture(name: "Lionel Messi", position: :forward, team: "Inter Miami CF")
      _suarez = subject_fixture(name: "Luis Suárez", position: :forward, team: "Inter Miami CF")

      _lo_celso =
        subject_fixture(name: "Giovani Lo Celso", position: :midfielder, team: "Tottenham")

      :ok
    end

    test "applies multiple filters simultaneously", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> element("#filter-form")
        |> render_change(%{q: "i", position: "forward", sort_by: "name"})

      assert html =~ "Lionel Messi"
      assert html =~ "Luis Suárez"
      refute html =~ "Giovani Lo Celso"
    end

    test "applies all filters together", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> element("#filter-form")
        |> render_change(%{q: "Lionel", position: "forward", sort_by: "name"})

      assert html =~ "Lionel"
      # Only forward players with "Lionel" in name should appear
    end
  end

  describe "Reset filters" do
    test "reset link clears all filters", %{conn: conn} do
      _subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/?q=Test&position=forward&sort_by=name")

      view |> element("a", "Reset") |> render_click()

      assert_patch(view, ~p"/")
    end

    test "shows all subjects after reset", %{conn: conn} do
      _subject1 = subject_fixture(name: "Player One")
      _subject2 = subject_fixture(name: "Player Two")

      {:ok, view, _html} = live(conn, ~p"/?q=One")

      refute render(view) =~ "Player Two"

      view |> element("a", "Reset") |> render_click()

      html = render(view)
      assert html =~ "Player One"
      assert html =~ "Player Two"
    end
  end

  describe "URL persistence" do
    test "loads with filters from URL", %{conn: conn} do
      messi = subject_fixture(name: "Lionel Messi", position: :forward)
      _suarez = subject_fixture(name: "Luis Suárez", position: :midfielder)

      {:ok, _view, html} = live(conn, ~p"/?q=Messi&position=forward")

      assert html =~ messi.name
      refute html =~ "Luis Suárez"
    end

    test "loads with sort parameters from URL", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/?sort_by=name&sort_order=desc")

      html = render(view)
      assert html =~ "▼ DESC"
    end
  end
end
