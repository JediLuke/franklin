defmodule Actions do
  defmacro __using__(_) do
    quote do
      alias Franklin.Actions.{CommandBuffer}
    end
  end

  alias GUI.Scene.Root, as: Franklin
  alias Structs.TidBit

  def new_buffer(:test) do
    new_buffer(%{
      type: :list,
      data: [
        {"iderieri", %{
          title: "Luke",
          text: "First note"
        }},
        {"ikey-heihderieri", %{
          title: "Leah",
          text: "Second note"
        }}
      ]
    })
  end

  def new_buffer(%{type: :list, data: data}) do
    Franklin.action({'NEW_LIST_BUFFER', data})
  end

  def save_new_tidbit(%TidBit{} = t) do
    Utilities.Data.append(t)
  end
end