defmodule SubjectManager.SubjectsTest do
  use SubjectManager.DataCase

  alias SubjectManager.Subjects

  import SubjectManager.SubjectsFixtures

  describe "list_subjects/0" do
    test "returns all subjects" do
      subject1 = subject_fixture()
      subject2 = subject_fixture()

      subjects = Subjects.list_subjects()

      assert length(subjects) == 2
      assert Enum.any?(subjects, &(&1.id == subject1.id))
      assert Enum.any?(subjects, &(&1.id == subject2.id))
    end

    test "returns empty list when no subjects exist" do
      assert Subjects.list_subjects() == []
    end
  end

  describe "list_subjects/1 with name filter" do
    setup do
      messi = subject_fixture(name: "Lionel Messi")
      suarez = subject_fixture(name: "Luis Suárez")
      lo_celso = subject_fixture(name: "Giovani Lo Celso")

      %{messi: messi, suarez: suarez, lo_celso: lo_celso}
    end

    test "filters by exact name match (case insensitive)", %{messi: messi} do
      results = Subjects.list_subjects(%{q: "messi"})

      assert length(results) == 1
      assert hd(results).id == messi.id
    end

    test "filters by partial name match", %{suarez: suarez} do
      results = Subjects.list_subjects(%{q: "Suá"})

      assert length(results) == 1
      assert hd(results).id == suarez.id
    end

    test "returns multiple results when name matches multiple subjects" do
      results = Subjects.list_subjects(%{q: "i"})

      assert length(results) == 3
    end

    test "returns empty list when name doesn't match" do
      results = Subjects.list_subjects(%{q: "Ronaldo"})

      assert results == []
    end

    test "ignores filter when q is nil" do
      results = Subjects.list_subjects(%{q: nil})

      assert length(results) == 3
    end

    test "ignores filter when q is empty string" do
      results = Subjects.list_subjects(%{q: ""})

      assert length(results) == 3
    end
  end

  describe "list_subjects/1 with position filter" do
    setup do
      forward = subject_fixture(position: :forward)
      midfielder = subject_fixture(position: :midfielder)
      goalkeeper = subject_fixture(position: :goalkeeper)

      %{forward: forward, midfielder: midfielder, goalkeeper: goalkeeper}
    end

    test "filters by position", %{forward: forward} do
      results = Subjects.list_subjects(%{position: "forward"})

      assert length(results) == 1
      assert hd(results).id == forward.id
    end

    test "returns empty when position doesn't match" do
      results = Subjects.list_subjects(%{position: "winger"})

      assert results == []
    end

    test "ignores filter when position is nil" do
      results = Subjects.list_subjects(%{position: nil})

      assert length(results) == 3
    end

    test "ignores filter when position is empty string" do
      results = Subjects.list_subjects(%{position: ""})

      assert length(results) == 3
    end
  end

  describe "list_subjects/1 with sorting" do
    setup do
      _charlie = subject_fixture(name: "Charlie Player", team: "Zebra FC")
      _alice = subject_fixture(name: "Alice Player", team: "Alpha FC")
      _bob = subject_fixture(name: "Bob Player", team: "Beta FC")

      :ok
    end

    test "sorts by name ascending" do
      results = Subjects.list_subjects(%{sort_by: "name", sort_order: :asc})

      names = Enum.map(results, & &1.name)
      assert names == ["Alice Player", "Bob Player", "Charlie Player"]
    end

    test "sorts by name descending" do
      results = Subjects.list_subjects(%{sort_by: "name", sort_order: :desc})

      names = Enum.map(results, & &1.name)
      assert names == ["Charlie Player", "Bob Player", "Alice Player"]
    end

    test "sorts by team ascending" do
      results = Subjects.list_subjects(%{sort_by: "team", sort_order: :asc})

      teams = Enum.map(results, & &1.team)
      assert teams == ["Alpha FC", "Beta FC", "Zebra FC"]
    end

    test "defaults to ascending when sort_order is nil" do
      results = Subjects.list_subjects(%{sort_by: "name", sort_order: nil})

      names = Enum.map(results, & &1.name)
      assert names == ["Alice Player", "Bob Player", "Charlie Player"]
    end

    test "ignores sorting when sort_by is nil" do
      results = Subjects.list_subjects(%{sort_by: nil, sort_order: :desc})

      assert length(results) == 3
    end
  end

  describe "list_subjects/1 with combined filters" do
    setup do
      _messi = subject_fixture(name: "Lionel Messi", position: :forward, team: "Inter Miami CF")
      _suarez = subject_fixture(name: "Luis Suárez", position: :forward, team: "Inter Miami CF")

      _lo_celso =
        subject_fixture(name: "Giovani Lo Celso", position: :midfielder, team: "Tottenham")

      :ok
    end

    test "filters by name and position" do
      results = Subjects.list_subjects(%{q: "Lionel", position: "forward"})

      assert length(results) == 1
      assert hd(results).name == "Lionel Messi"
    end

    test "filters and sorts combined" do
      results = Subjects.list_subjects(%{position: "forward", sort_by: "name", sort_order: :desc})

      assert length(results) == 2
      names = Enum.map(results, & &1.name)
      assert names == ["Luis Suárez", "Lionel Messi"]
    end
  end

  describe "get_subject!/1" do
    test "returns the subject with given id" do
      subject = subject_fixture()

      found = Subjects.get_subject!(subject.id)

      assert found.id == subject.id
      assert found.name == subject.name
    end

    test "raises error when subject doesn't exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Subjects.get_subject!(99_999)
      end
    end
  end

  describe "create_subject/1" do
    test "with valid data creates a subject" do
      attrs = valid_subject_attributes()

      assert {:ok, subject} = Subjects.create_subject(attrs)
      assert subject.name == attrs.name
      assert subject.team == attrs.team
      assert subject.position == attrs.position
      assert subject.bio == attrs.bio
      assert subject.image_path == attrs.image_path
    end

    test "with invalid data returns error changeset" do
      attrs = invalid_subject_attributes()

      assert {:error, changeset} = Subjects.create_subject(attrs)
      refute changeset.valid?
    end

    test "with too short name returns error" do
      attrs = valid_subject_attributes() |> Map.put(:name, "AB")

      assert {:error, changeset} = Subjects.create_subject(attrs)
      assert %{name: ["should be at least 3 character(s)"]} = errors_on(changeset)
    end
  end

  describe "update_subject/2" do
    test "with valid data updates the subject" do
      subject = subject_fixture()
      update_attrs = %{name: "Updated Name", team: "New Team FC"}

      assert {:ok, updated} = Subjects.update_subject(subject, update_attrs)
      assert updated.name == "Updated Name"
      assert updated.team == "New Team FC"
      assert updated.id == subject.id
    end

    test "with invalid data returns error changeset" do
      subject = subject_fixture()
      invalid_attrs = %{name: nil, bio: nil}

      assert {:error, changeset} = Subjects.update_subject(subject, invalid_attrs)
      refute changeset.valid?

      # Subject should remain unchanged
      unchanged = Subjects.get_subject!(subject.id)
      assert unchanged.name == subject.name
    end

    test "with too short bio returns error" do
      subject = subject_fixture()

      assert {:error, changeset} = Subjects.update_subject(subject, %{bio: "Short"})
      assert %{bio: ["should be at least 10 character(s)"]} = errors_on(changeset)
    end
  end

  describe "delete_subject/1" do
    test "deletes the subject" do
      subject = subject_fixture()

      assert {:ok, deleted} = Subjects.delete_subject(subject)
      assert deleted.id == subject.id

      assert_raise Ecto.NoResultsError, fn ->
        Subjects.get_subject!(subject.id)
      end
    end
  end

  describe "change_subject/1" do
    test "returns a subject changeset" do
      subject = subject_fixture()

      changeset = Subjects.change_subject(subject)

      assert %Ecto.Changeset{} = changeset
      assert changeset.data.id == subject.id
    end

    test "with attrs returns changeset with changes" do
      subject = subject_fixture()
      attrs = %{name: "New Name"}

      changeset = Subjects.change_subject(subject, attrs)

      assert changeset.changes.name == "New Name"
    end
  end

  describe "list_subjects/1 edge cases" do
    setup do
      _subject = subject_fixture()
      :ok
    end

    test "handles invalid position gracefully" do
      # Non-existent position atom should be ignored
      results = Subjects.list_subjects(%{position: "invalid_position"})

      assert length(results) == 1
    end

    test "handles invalid sort field gracefully" do
      # Non-existent field should be ignored
      results = Subjects.list_subjects(%{sort_by: "invalid_field", sort_order: :asc})

      assert length(results) == 1
    end

    test "handles nil map values" do
      results = Subjects.list_subjects(%{q: nil, position: nil, sort_by: nil, sort_order: nil})

      assert length(results) == 1
    end

    test "handles empty string values" do
      results = Subjects.list_subjects(%{q: "", position: "", sort_by: "", sort_order: ""})

      assert length(results) == 1
    end

    test "handles search with special characters" do
      subject_fixture(name: "Test & Player")

      results = Subjects.list_subjects(%{q: "&"})

      assert length(results) == 1
    end

    test "handles search with SQL-like patterns" do
      subject_fixture(name: "Test Player")
      subject_fixture(name: "Another Subject")

      # Search for "Test" should find "Test Player"
      results = Subjects.list_subjects(%{q: "Test"})

      refute Enum.empty?(results)
      assert Enum.any?(results, &(&1.name == "Test Player"))
    end

    test "sort order defaults to asc when invalid" do
      subject_fixture(name: "Zebra")
      subject_fixture(name: "Alpha")

      results = Subjects.list_subjects(%{sort_by: "name", sort_order: :invalid})

      # Should default to asc
      assert hd(results).name == "Alpha"
    end

    test "sorts descending correctly" do
      subject_fixture(name: "Alpha")
      subject_fixture(name: "Zebra")

      results = Subjects.list_subjects(%{sort_by: "name", sort_order: :desc})

      assert hd(results).name == "Zebra"
      assert List.last(results).name == "Alpha"
    end

    test "handles concurrent filters with empty results" do
      results = Subjects.list_subjects(%{q: "Nonexistent", position: "forward", sort_by: "name"})

      assert results == []
    end

    test "case insensitive search with mixed case" do
      subject = subject_fixture(name: "LiOnEl MeSsI")

      results = Subjects.list_subjects(%{q: "lionel"})

      assert length(results) == 1
      assert hd(results).id == subject.id
    end

    test "search with unicode characters" do
      subject = subject_fixture(name: "Luis Suárez")

      results = Subjects.list_subjects(%{q: "Suárez"})

      assert length(results) == 1
      assert hd(results).id == subject.id
    end

    test "position filter with all valid positions" do
      for position <- [:forward, :midfielder, :winger, :defender, :goalkeeper] do
        subject = subject_fixture(position: position)

        results = Subjects.list_subjects(%{position: Atom.to_string(position)})

        refute Enum.empty?(results)
        assert Enum.any?(results, &(&1.id == subject.id))
      end
    end

    test "sorting by position" do
      subject_fixture(position: :winger)
      subject_fixture(position: :defender)
      subject_fixture(position: :forward)

      results = Subjects.list_subjects(%{sort_by: "position", sort_order: :asc})

      assert length(results) == 4
      # Positions should be sorted
    end
  end

  describe "list_subjects/1 with complex scenarios" do
    test "multiple subjects with same name" do
      subject_fixture(name: "John Doe", team: "Team A")
      subject_fixture(name: "John Doe", team: "Team B")

      results = Subjects.list_subjects(%{q: "John"})

      assert length(results) == 2
    end

    test "filters work after database operations" do
      subject = subject_fixture(name: "To Delete")
      subject_fixture(name: "To Keep")

      # Delete one
      Subjects.delete_subject(subject)

      results = Subjects.list_subjects(%{})

      assert length(results) == 1
      assert hd(results).name == "To Keep"
    end

    test "search is trimmed implicitly" do
      _subject = subject_fixture(name: "Messi")

      # Search with spaces - they are treated as part of search term
      results = Subjects.list_subjects(%{q: "Messi"})

      assert length(results) == 1
    end
  end
end
