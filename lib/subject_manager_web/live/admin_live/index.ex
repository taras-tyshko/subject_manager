defmodule SubjectManagerWeb.AdminLive.Index do
  use SubjectManagerWeb, :live_view

  alias SubjectManager.Subjects

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Admin - Manage Subjects")
      |> assign(subjects: Subjects.list_subjects())

    {:ok, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    subject = Subjects.get_subject!(id)
    {:ok, _} = Subjects.delete_subject(subject)

    socket =
      socket
      |> put_flash(:info, "Subject deleted successfully")
      |> assign(subjects: Subjects.list_subjects())

    {:noreply, socket}
  end

  def handle_info({:subject_saved, _subject}, socket) do
    socket =
      socket
      |> put_flash(:info, "Subject saved successfully")
      |> assign(subjects: Subjects.list_subjects())

    {:noreply, socket}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="admin-index">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold">Manage Subjects</h1>
        <.link navigate={~p"/admin/new"} class="button">
          Add New Subject
        </.link>
      </div>

      <.link navigate={~p"/"} class="text-sky-600 hover:text-sky-800 mb-4 inline-block">
        ← Back to Public View
      </.link>

      <div class="overflow-x-auto bg-white shadow-md rounded-lg">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Image
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Name
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Team
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Position
              </th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr :for={subject <- @subjects} id={"subject-row-#{subject.id}"}>
              <td class="px-6 py-4 whitespace-nowrap">
                <img
                  src={subject.image_path}
                  alt={subject.name}
                  class="h-12 w-12 rounded-full object-cover"
                />
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm font-medium text-gray-900">{subject.name}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-500">{subject.team}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                  {subject.position}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                <.link navigate={~p"/admin/#{subject}/edit"} class="text-sky-600 hover:text-sky-900">
                  Edit
                </.link>
                <a
                  href="#"
                  phx-click="delete"
                  phx-value-id={subject.id}
                  data-confirm="Are you sure you want to delete this subject?"
                  class="text-red-600 hover:text-red-900"
                >
                  Delete
                </a>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
