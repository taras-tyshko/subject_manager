defmodule SubjectManagerWeb.AdminLive.Form do
  use SubjectManagerWeb, :live_view

  alias SubjectManager.Subjects
  alias SubjectManager.Subjects.Subject

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Subject")
    |> assign(:subject, %Subject{})
    |> assign_form(Subjects.change_subject(%Subject{}))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    subject = Subjects.get_subject!(id)

    socket
    |> assign(:page_title, "Edit Subject")
    |> assign(:subject, subject)
    |> assign_form(Subjects.change_subject(subject))
  end

  def handle_event("validate", %{"subject" => subject_params}, socket) do
    changeset =
      socket.assigns.subject
      |> Subjects.change_subject(subject_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"subject" => subject_params}, socket) do
    save_subject(socket, socket.assigns.live_action, subject_params)
  end

  defp save_subject(socket, :edit, subject_params) do
    case Subjects.update_subject(socket.assigns.subject, subject_params) do
      {:ok, _subject} ->
        {:noreply,
         socket
         |> put_flash(:info, "Subject updated successfully")
         |> push_navigate(to: ~p"/admin")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_subject(socket, :new, subject_params) do
    case Subjects.create_subject(subject_params) do
      {:ok, _subject} ->
        {:noreply,
         socket
         |> put_flash(:info, "Subject created successfully")
         |> push_navigate(to: ~p"/admin")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl">
      <.link navigate={~p"/admin"} class="text-sky-600 hover:text-sky-800 mb-4 inline-block">
        ← Back to Admin
      </.link>

      <.header>
        {@page_title}
      </.header>

      <.simple_form for={@form} id="subject-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:team]} type="text" label="Team" />
        <.input
          field={@form[:position]}
          type="select"
          label="Position"
          prompt="Choose a position"
          options={[
            Forward: :forward,
            Midfielder: :midfielder,
            Winger: :winger,
            Defender: :defender,
            Goalkeeper: :goalkeeper
          ]}
        />
        <.input field={@form[:bio]} type="textarea" label="Bio" />
        <.input
          field={@form[:image_path]}
          type="text"
          label="Image Path"
          placeholder="/images/player-name.jpg"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Subject</.button>
          <.link navigate={~p"/admin"} class="text-sm text-gray-600 hover:text-gray-800">
            Cancel
          </.link>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
