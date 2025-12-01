defmodule SubjectManagerWeb.AdminLive.FormTest do
  use SubjectManagerWeb.ConnCase

  import Phoenix.LiveViewTest
  import SubjectManager.SubjectsFixtures

  alias SubjectManager.Subjects

  describe "New subject form" do
    test "renders empty form", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/new")

      assert html =~ "New Subject"
      assert html =~ "Name"
      assert html =~ "Team"
      assert html =~ "Position"
      assert html =~ "Bio"
      assert html =~ "Image Path"
    end

    test "has Save Subject button", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      assert view |> element("button", "Save Subject") |> has_element?()
    end

    test "has Cancel link", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      assert view |> element("a", "Cancel") |> has_element?()
    end

    test "has Back to Admin link", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      assert view |> element("a", "Back to Admin") |> has_element?()
    end

    test "form fields are empty", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      assert view |> element("input[name='subject[name]'][value='']") |> has_element?()
    end

    test "position dropdown has all options", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/new")

      assert html =~ "Forward"
      assert html =~ "Midfielder"
      assert html =~ "Winger"
      assert html =~ "Defender"
      assert html =~ "Goalkeeper"
    end
  end

  describe "Create subject" do
    test "creates subject with valid data", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      attrs = valid_subject_attributes()

      {:ok, _view, html} =
        view
        |> form("#subject-form", subject: attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin")

      assert html =~ "Subject created successfully"
      assert html =~ attrs.name
    end

    test "saves subject to database", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      attrs = valid_subject_attributes()

      view
      |> form("#subject-form", subject: attrs)
      |> render_submit()

      subjects = Subjects.list_subjects()
      assert Enum.any?(subjects, &(&1.name == attrs.name))
    end

    test "redirects to admin index after successful create", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      attrs = valid_subject_attributes()

      assert {:ok, _view, _html} =
               view
               |> form("#subject-form", subject: attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin")
    end

    test "displays flash message after create", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      attrs = valid_subject_attributes()

      {:ok, _view, html} =
        view
        |> form("#subject-form", subject: attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin")

      assert html =~ "Subject created successfully"
    end
  end

  describe "Form validation" do
    test "validates required fields", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      html =
        view
        |> form("#subject-form", subject: invalid_subject_attributes())
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end

    test "validates name minimum length", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      attrs = valid_subject_attributes() |> Map.put(:name, "AB")

      html =
        view
        |> form("#subject-form", subject: attrs)
        |> render_change()

      assert html =~ "should be at least 3 character"
    end

    test "validates bio minimum length", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      attrs = valid_subject_attributes() |> Map.put(:bio, "Short")

      html =
        view
        |> form("#subject-form", subject: attrs)
        |> render_change()

      assert html =~ "should be at least 10 character"
    end

    test "does not submit with invalid data", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      html =
        view
        |> form("#subject-form", subject: invalid_subject_attributes())
        |> render_submit()

      assert html =~ "can&#39;t be blank"
      refute html =~ "Subject created successfully"
    end

    test "validates in real-time on change", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      # Start with empty name
      html =
        view
        |> form("#subject-form", subject: %{name: ""})
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end
  end

  describe "Edit subject form" do
    test "renders form with existing subject data", %{conn: conn} do
      subject = subject_fixture(name: "Lionel Messi", team: "Inter Miami CF")

      {:ok, _view, html} = live(conn, ~p"/admin/#{subject.id}/edit")

      assert html =~ "Edit Subject"
      assert html =~ "Lionel Messi"
      assert html =~ "Inter Miami CF"
    end

    test "form fields are pre-filled with subject data", %{conn: conn} do
      subject = subject_fixture(name: "Lionel Messi", bio: "One of the greatest players.")

      {:ok, view, _html} = live(conn, ~p"/admin/#{subject.id}/edit")

      assert view
             |> element("input[name='subject[name]'][value='Lionel Messi']")
             |> has_element?()

      assert render(view) =~ "One of the greatest players."
    end

    test "position dropdown shows current position selected", %{conn: conn} do
      subject = subject_fixture(position: :midfielder)

      {:ok, _view, html} = live(conn, ~p"/admin/#{subject.id}/edit")

      # Check that midfielder option exists and form is populated
      assert html =~ "midfielder"
      assert html =~ "Midfielder"
    end
  end

  describe "Update subject" do
    test "updates subject with valid data", %{conn: conn} do
      subject = subject_fixture(name: "Original Name")

      {:ok, view, _html} = live(conn, ~p"/admin/#{subject.id}/edit")

      {:ok, _view, html} =
        view
        |> form("#subject-form", subject: %{name: "Updated Name"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin")

      assert html =~ "Subject updated successfully"
      assert html =~ "Updated Name"
      refute html =~ "Original Name"
    end

    test "updates subject in database", %{conn: conn} do
      subject = subject_fixture(name: "Original Name", team: "Original Team")

      {:ok, view, _html} = live(conn, ~p"/admin/#{subject.id}/edit")

      view
      |> form("#subject-form", subject: %{name: "Updated Name", team: "Updated Team"})
      |> render_submit()

      updated = Subjects.get_subject!(subject.id)
      assert updated.name == "Updated Name"
      assert updated.team == "Updated Team"
    end

    test "redirects to admin index after successful update", %{conn: conn} do
      subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/admin/#{subject.id}/edit")

      assert {:ok, _view, _html} =
               view
               |> form("#subject-form", subject: %{name: "New Name"})
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin")
    end

    test "displays flash message after update", %{conn: conn} do
      subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/admin/#{subject.id}/edit")

      {:ok, _view, html} =
        view
        |> form("#subject-form", subject: %{name: "New Name"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin")

      assert html =~ "Subject updated successfully"
    end

    test "does not update with invalid data", %{conn: conn} do
      subject = subject_fixture(name: "Original Name")

      {:ok, view, _html} = live(conn, ~p"/admin/#{subject.id}/edit")

      html =
        view
        |> form("#subject-form", subject: %{name: nil})
        |> render_submit()

      assert html =~ "can&#39;t be blank"

      # Subject should remain unchanged in database
      unchanged = Subjects.get_subject!(subject.id)
      assert unchanged.name == "Original Name"
    end
  end

  describe "Form navigation" do
    test "Cancel link on new form navigates to admin index", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      link = view |> element("a", "Cancel")
      assert link |> render() =~ ~s(href="/admin")
    end

    test "Cancel link on edit form navigates to admin index", %{conn: conn} do
      subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/admin/#{subject.id}/edit")

      link = view |> element("a", "Cancel")
      assert link |> render() =~ ~s(href="/admin")
    end

    test "Back to Admin link works on new form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/new")

      link = view |> element("a", "Back to Admin")
      assert link |> render() =~ ~s(href="/admin")
    end

    test "Back to Admin link works on edit form", %{conn: conn} do
      subject = subject_fixture()

      {:ok, view, _html} = live(conn, ~p"/admin/#{subject.id}/edit")

      link = view |> element("a", "Back to Admin")
      assert link |> render() =~ ~s(href="/admin")
    end
  end

  describe "Form errors" do
    test "edit form returns 404 for non-existent subject", %{conn: conn} do
      assert_error_sent 404, fn ->
        live(conn, ~p"/admin/99999/edit")
      end
    end
  end

  describe "Form with all position types" do
    for position <- [:forward, :midfielder, :winger, :defender, :goalkeeper] do
      test "creates subject with #{position} position", %{conn: conn} do
        {:ok, view, _html} = live(conn, ~p"/admin/new")

        attrs = valid_subject_attributes() |> Map.put(:position, unquote(position))

        {:ok, _view, html} =
          view
          |> form("#subject-form", subject: attrs)
          |> render_submit()
          |> follow_redirect(conn, ~p"/admin")

        assert html =~ "Subject created successfully"
      end
    end
  end
end
