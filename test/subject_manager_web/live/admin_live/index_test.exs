defmodule SubjectManagerWeb.AdminLive.IndexTest do
  use SubjectManagerWeb.ConnCase

  import Phoenix.LiveViewTest
  import SubjectManager.SubjectsFixtures

  describe "Admin Index page" do
    test "displays list of subjects in table", %{conn: conn} do
      subject1 = subject_fixture(name: "Lionel Messi")
      subject2 = subject_fixture(name: "Luis Suárez")

      {:ok, _view, html} = live(conn, ~p"/admin")

      assert html =~ "Manage Subjects"
      assert html =~ subject1.name
      assert html =~ subject2.name
    end

    test "displays subject details in table columns", %{conn: conn} do
      subject =
        subject_fixture(
          name: "Lionel Messi",
          team: "Inter Miami CF",
          position: :forward
        )

      {:ok, _view, html} = live(conn, ~p"/admin")

      assert html =~ subject.name
      assert html =~ subject.team
      assert html =~ "forward"
    end

    test "displays subject images in table", %{conn: conn} do
      subject = subject_fixture(image_path: "/images/test-player.jpg")

      {:ok, _view, html} = live(conn, ~p"/admin")

      assert html =~ subject.image_path
      assert html =~ ~s(<img)
    end

    test "has Add New Subject button", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin")

      assert view |> element("a", "Add New Subject") |> has_element?()
    end

    test "Add New Subject button navigates to new form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin")

      link = view |> element("a", "Add New Subject")
      assert link |> render() =~ ~s(href="/admin/new")
    end

    test "has Edit link for each subject", %{conn: conn} do
      subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/admin")

      assert view |> element("a[href='/admin/#{subject.id}/edit']", "Edit") |> has_element?()
    end

    test "has Delete link for each subject", %{conn: conn} do
      subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/admin")

      assert view
             |> element("a[phx-click='delete'][phx-value-id='#{subject.id}']", "Delete")
             |> has_element?()
    end

    test "has Back to Public View link", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin")

      assert view |> element("a", "Back to Public View") |> has_element?()
    end

    test "uses admin-index CSS class", %{conn: conn} do
      _subject = subject_fixture()

      {:ok, _view, html} = live(conn, ~p"/admin")

      assert html =~ ~s(class="admin-index")
    end
  end

  describe "Delete subject" do
    test "deletes subject when confirmed", %{conn: conn} do
      subject = subject_fixture(name: "Test Player")

      {:ok, view, _html} = live(conn, ~p"/admin")

      # Delete the subject
      view |> element("a[phx-value-id='#{subject.id}']", "Delete") |> render_click()

      # Subject should be removed from the list
      html = render(view)
      refute html =~ "Test Player"
    end

    test "shows flash message after successful deletion", %{conn: conn} do
      subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/admin")

      view |> element("a[phx-value-id='#{subject.id}']", "Delete") |> render_click()

      assert render(view) =~ "Subject deleted successfully"
    end

    test "removes subject from database", %{conn: conn} do
      subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/admin")

      view |> element("a[phx-value-id='#{subject.id}']", "Delete") |> render_click()

      assert_raise Ecto.NoResultsError, fn ->
        SubjectManager.Subjects.get_subject!(subject.id)
      end
    end

    test "delete link has confirmation attribute", %{conn: conn} do
      _subject = subject_fixture()

      {:ok, _view, html} = live(conn, ~p"/admin")

      assert html =~ ~s(data-confirm="Are you sure you want to delete this subject?")
    end
  end

  describe "Admin table structure" do
    test "has proper table headers", %{conn: conn} do
      _subject = subject_fixture()

      {:ok, _view, html} = live(conn, ~p"/admin")

      assert html =~ "Image"
      assert html =~ "Name"
      assert html =~ "Team"
      assert html =~ "Position"
      assert html =~ "Actions"
    end

    test "displays multiple subjects in rows", %{conn: conn} do
      subject1 = subject_fixture(name: "Player One")
      subject2 = subject_fixture(name: "Player Two")
      subject3 = subject_fixture(name: "Player Three")

      {:ok, _view, html} = live(conn, ~p"/admin")

      assert html =~ subject1.name
      assert html =~ subject2.name
      assert html =~ subject3.name
    end

    test "each row has unique id attribute", %{conn: conn} do
      subject1 = subject_fixture()
      subject2 = subject_fixture()

      {:ok, _view, html} = live(conn, ~p"/admin")

      assert html =~ ~s(id="subject-row-#{subject1.id}")
      assert html =~ ~s(id="subject-row-#{subject2.id}")
    end
  end

  describe "Admin navigation" do
    test "Edit link navigates to edit form", %{conn: conn} do
      subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/admin")

      link = view |> element("a[href='/admin/#{subject.id}/edit']", "Edit")
      assert link |> render() =~ "/admin/#{subject.id}/edit"
    end

    test "Back to Public View navigates to home", %{conn: conn} do
      _subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/admin")

      link = view |> element("a", "Back to Public View")
      assert link |> render() =~ ~s(href="/")
    end
  end

  describe "Admin page with many subjects" do
    test "displays all subjects without pagination", %{conn: conn} do
      subjects =
        for i <- 1..15 do
          subject_fixture(name: "Player #{i}")
        end

      {:ok, _view, html} = live(conn, ~p"/admin")

      for subject <- subjects do
        assert html =~ subject.name
      end
    end
  end

  describe "Admin page with different positions" do
    test "displays position badges correctly", %{conn: conn} do
      _forward = subject_fixture(position: :forward)
      _midfielder = subject_fixture(position: :midfielder)
      _goalkeeper = subject_fixture(position: :goalkeeper)

      {:ok, _view, html} = live(conn, ~p"/admin")

      assert html =~ "forward"
      assert html =~ "midfielder"
      assert html =~ "goalkeeper"
    end
  end

  describe "handle_info/2" do
    test "handles :subject_saved message and reloads subjects", %{conn: conn} do
      subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/admin")

      # Simulate subject_saved message
      send(view.pid, {:subject_saved, subject})

      # Give it a moment to process
      :timer.sleep(10)

      html = render(view)
      assert html =~ subject.name
      assert html =~ "Subject saved successfully"
    end

    test "ignores unknown messages", %{conn: conn} do
      _subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/admin")

      # Send unknown message - should not crash
      send(view.pid, {:unknown_message, "data"})
      send(view.pid, :random_atom)

      # View should still work
      :timer.sleep(10)
      assert render(view)
    end
  end

  describe "error handling" do
    test "maintains state correctly", %{conn: conn} do
      subject = subject_fixture()

      {:ok, _view, html} = live(conn, ~p"/admin")

      # State should be consistent
      assert html =~ subject.name
      assert html =~ "Manage Subjects"
    end
  end
end
