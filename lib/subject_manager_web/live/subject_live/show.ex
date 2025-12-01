defmodule SubjectManagerWeb.SubjectLive.Show do
  use SubjectManagerWeb, :live_view

  alias SubjectManager.Subjects
  import SubjectManagerWeb.CustomComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    subject = Subjects.get_subject!(id)

    socket =
      socket
      |> assign(page_title: subject.name)
      |> assign(subject: subject)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="subject-show">
      <.link navigate={~p"/"} class="back-link">
        ← Back to Subjects
      </.link>

      <div class="subject-details">
        <div class="subject-image">
          <img src={@subject.image_path} alt={@subject.name} />
        </div>

        <div class="subject-info">
          <h1>{@subject.name}</h1>

          <div class="subject-meta">
            <div class="meta-item">
              <span class="meta-label">Team:</span>
              <span class="meta-value">{@subject.team}</span>
            </div>

            <div class="meta-item">
              <span class="meta-label">Position:</span>
              <.badge status={@subject.position} />
            </div>
          </div>

          <div class="subject-bio">
            <h2>Biography</h2>
            <p>{@subject.bio}</p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
