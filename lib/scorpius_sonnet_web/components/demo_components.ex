defmodule ScorpiusSonnetWeb.DemoComponents do
  use Phoenix.Component

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :path, :string, required: true

  def demo_card(assigns) do
    ~H"""
    <div class="card">
      <.link navigate={@path} class="block p-6 bg-white rounded-lg shadow hover:shadow-lg">
        <h2 class="text-xl font-semibold mb-2"><%= @title %></h2>
        <p class="text-gray-600"><%= @description %></p>
      </.link>
    </div>
    """
  end
end
