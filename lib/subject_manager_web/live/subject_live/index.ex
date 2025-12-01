defmodule SubjectManagerWeb.SubjectLive.Index do
  use SubjectManagerWeb, :live_view

  alias SubjectManager.Subjects
  import SubjectManagerWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Subjects")

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    filters = %{
      q: params["q"],
      position: params["position"],
      sort_by: params["sort_by"],
      sort_order: get_sort_order(params["sort_order"])
    }

    socket =
      socket
      |> assign(subjects: Subjects.list_subjects(filters))
      |> assign(filters: filters)
      |> assign(form: to_form(params))

    {:noreply, socket}
  end

  defp get_sort_order("desc"), do: :desc
  defp get_sort_order(_), do: :asc

  def handle_event("filter", params, socket) do
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  def handle_event("toggle_sort", %{"field" => field}, socket) do
    current_sort_by = socket.assigns.filters.sort_by
    current_sort_order = socket.assigns.filters.sort_order

    # Toggle order if clicking the same field, otherwise default to asc
    new_sort_order =
      if current_sort_by == field do
        if current_sort_order == :asc, do: :desc, else: :asc
      else
        :asc
      end

    filters =
      Map.merge(socket.assigns.form.params, %{
        "sort_by" => field,
        "sort_order" => Atom.to_string(new_sort_order)
      })

    {:noreply, push_patch(socket, to: ~p"/?#{filters}")}
  end

  def render(assigns) do
    ~H"""
    <div class="subject-index">
      <.filter_form form={@form} filters={@filters} />

      <div class="subjects" id="subjects">
        <div id="empty" class="no-results only:block hidden">
          No subjects found. Try changing your filters.
        </div>
        <.subject :for={subject <- @subjects} subject={subject} dom_id={"subject-#{subject.id}"} />
      </div>
    </div>
    """
  end

  attr(:subject, SubjectManager.Subjects.Subject, required: true)
  attr(:dom_id, :string, required: true)

  def subject(assigns) do
    ~H"""
    <.link navigate={~p"/subjects/#{@subject}"} id={@dom_id}>
      <div class="card">
        <img src={@subject.image_path} />
        <h2>{@subject.name}</h2>
        <div class="details">
          <div class="team">
            {@subject.team}
          </div>
          <.badge status={@subject.position} />
        </div>
      </div>
    </.link>
    """
  end

  attr(:form, Phoenix.HTML.Form, required: true)
  attr(:filters, :map, required: true)

  def filter_form(assigns) do
    ~H"""
    <.form for={@form} id="filter-form" phx-change="filter">
      <.input field={@form[:q]} placeholder="Search..." autocomplete="off" />
      <.input
        type="select"
        field={@form[:position]}
        prompt="Position"
        options={[
          Forward: "forward",
          Midfielder: "midfielder",
          Winger: "winger",
          Defender: "defender",
          Goalkeeper: "goalkeeper"
        ]}
      />
      <.input
        type="select"
        field={@form[:sort_by]}
        prompt="Sort By"
        options={[
          Name: "name",
          Team: "team",
          Position: "position"
        ]}
      />

      <%= if @filters.sort_by do %>
        <button
          type="button"
          phx-click="toggle_sort"
          phx-value-field={@filters.sort_by}
          class="sort-order-toggle"
        >
          {if @filters.sort_order == :asc, do: "▲ ASC", else: "▼ DESC"}
        </button>
      <% end %>

      <.link patch={~p"/"}>
        Reset
      </.link>
    </.form>
    """
  end
end
