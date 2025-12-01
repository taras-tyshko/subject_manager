defmodule SubjectManager.SubjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SubjectManager.Subjects` context.
  """

  alias SubjectManager.Subjects

  @doc """
  Generate a subject with valid attributes.
  """
  def subject_fixture(attrs \\ %{}) do
    {:ok, subject} =
      attrs
      |> Enum.into(valid_subject_attributes())
      |> Subjects.create_subject()

    subject
  end

  @doc """
  Returns a map of valid subject attributes.
  """
  def valid_subject_attributes do
    %{
      name: "Test Player #{System.unique_integer([:positive])}",
      team: "Test Team FC",
      position: :forward,
      bio: "This is a test biography that is long enough to pass validation requirements.",
      image_path: "/images/test-player.jpg"
    }
  end

  @doc """
  Returns a map of invalid subject attributes.
  """
  def invalid_subject_attributes do
    %{
      name: nil,
      team: nil,
      position: nil,
      bio: nil,
      image_path: nil
    }
  end
end
