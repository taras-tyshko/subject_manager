defmodule SubjectManager.Subjects do
  @moduledoc """
  Context module for managing subjects (football players).
  Provides functions for listing, filtering, sorting, and CRUD operations.
  """

  import Ecto.Query
  alias SubjectManager.Repo
  alias SubjectManager.Subjects.Subject

  @doc """
  Returns the list of subjects.
  """
  def list_subjects do
    Repo.all(Subject)
  end

  @doc """
  Returns the list of subjects with optional filters.

  ## Options
    * `:q` - search query for name
    * `:position` - filter by position
    * `:sort_by` - field to sort by (name, team, position)
    * `:sort_order` - :asc or :desc
  """
  def list_subjects(filters) when is_map(filters) do
    Subject
    |> apply_search_filter(filters[:q])
    |> apply_position_filter(filters[:position])
    |> apply_sorting(filters[:sort_by], filters[:sort_order])
    |> Repo.all()
  end

  defp apply_search_filter(query, nil), do: query
  defp apply_search_filter(query, ""), do: query

  defp apply_search_filter(query, search_term) do
    search_pattern = "%#{String.downcase(search_term)}%"
    where(query, [s], like(fragment("lower(?)", s.name), ^search_pattern))
  end

  defp apply_position_filter(query, nil), do: query
  defp apply_position_filter(query, ""), do: query

  defp apply_position_filter(query, position)
       when position in ~w(forward midfielder winger defender goalkeeper) do
    position_atom = String.to_existing_atom(position)
    where(query, [s], s.position == ^position_atom)
  end

  defp apply_position_filter(query, _invalid_position), do: query

  defp apply_sorting(query, nil, _order), do: query
  defp apply_sorting(query, "", _order), do: query

  defp apply_sorting(query, sort_by, sort_order) when sort_by in ~w(name team position) do
    sort_field = String.to_existing_atom(sort_by)
    order = if sort_order == :desc, do: :desc, else: :asc

    order_by(query, [s], [{^order, field(s, ^sort_field)}])
  end

  defp apply_sorting(query, _invalid_sort_by, _order), do: query

  @doc """
  Gets a single subject.

  Raises `Ecto.NoResultsError` if the Subject does not exist.
  """
  def get_subject!(id), do: Repo.get!(Subject, id)

  @doc """
  Creates a subject.
  """
  def create_subject(attrs \\ %{}) do
    %Subject{}
    |> Subject.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subject.
  """
  def update_subject(%Subject{} = subject, attrs) do
    subject
    |> Subject.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subject.
  """
  def delete_subject(%Subject{} = subject) do
    Repo.delete(subject)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subject changes.
  """
  def change_subject(%Subject{} = subject, attrs \\ %{}) do
    Subject.changeset(subject, attrs)
  end
end
