defmodule SubjectManager.Subjects.SubjectTest do
  use SubjectManager.DataCase

  alias SubjectManager.Subjects.Subject

  import SubjectManager.SubjectsFixtures

  describe "changeset/2" do
    test "with valid attributes" do
      attrs = valid_subject_attributes()
      changeset = Subject.changeset(%Subject{}, attrs)

      assert changeset.valid?
    end

    test "with invalid attributes" do
      attrs = invalid_subject_attributes()
      changeset = Subject.changeset(%Subject{}, attrs)

      refute changeset.valid?
      assert %{name: ["can't be blank"]} = errors_on(changeset)
      assert %{team: ["can't be blank"]} = errors_on(changeset)
      assert %{position: ["can't be blank"]} = errors_on(changeset)
      assert %{bio: ["can't be blank"]} = errors_on(changeset)
      assert %{image_path: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates name minimum length" do
      attrs = valid_subject_attributes() |> Map.put(:name, "AB")
      changeset = Subject.changeset(%Subject{}, attrs)

      refute changeset.valid?
      assert %{name: ["should be at least 3 character(s)"]} = errors_on(changeset)
    end

    test "validates bio minimum length" do
      attrs = valid_subject_attributes() |> Map.put(:bio, "Short")
      changeset = Subject.changeset(%Subject{}, attrs)

      refute changeset.valid?
      assert %{bio: ["should be at least 10 character(s)"]} = errors_on(changeset)
    end

    test "validates position is a valid enum value" do
      valid_positions = [:forward, :midfielder, :winger, :defender, :goalkeeper]

      for position <- valid_positions do
        attrs = valid_subject_attributes() |> Map.put(:position, position)
        changeset = Subject.changeset(%Subject{}, attrs)

        assert changeset.valid?, "Expected #{position} to be valid"
      end
    end

    test "rejects invalid position enum value" do
      attrs = valid_subject_attributes() |> Map.put(:position, :invalid_position)
      changeset = Subject.changeset(%Subject{}, attrs)

      refute changeset.valid?
      assert %{position: ["is invalid"]} = errors_on(changeset)
    end

    test "allows all fields to be present" do
      attrs = %{
        name: "Lionel Messi",
        team: "Inter Miami CF",
        position: :forward,
        bio: "One of the greatest players of all time with multiple awards.",
        image_path: "/images/lionel-messi.jpg"
      }

      changeset = Subject.changeset(%Subject{}, attrs)

      assert changeset.valid?
      assert changeset.changes.name == "Lionel Messi"
      assert changeset.changes.team == "Inter Miami CF"
      assert changeset.changes.position == :forward
    end
  end
end
