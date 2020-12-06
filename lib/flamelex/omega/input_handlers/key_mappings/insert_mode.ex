defmodule Flamelex.GUI.InputHandler.InsertMode do
  @moduledoc false
  use Flamelex.ProjectAliases
  use Flamelex.GUI.ScenicEventsDefinitions
  alias Flamelex.Structs.OmegaState
  alias Flamelex.GUI.Control.Input.KeyMapping

  def handle(%OmegaState{} = state, input) when input in @valid_command_buffer_inputs do
    case KeyMapping.lookup(state, input) do
      :ignore_input ->
          state |> OmegaState.add_to_history(input)
      {:apply_mfa, {module, function, args}} ->
          Kernel.apply(module, function, args)
            |> IO.inspect
          state |> OmegaState.add_to_history(input)
    end
  end





  # def handle_input(%Flamelex.Structs.OmegaState{mode: :insert} = state, @enter_key = input) do
  #   cursor_pos =
  #     {:gui_component, state.active_buffer}
  #     |> ProcessRegistry.find!()
  #     |> GenServer.call(:get_cursor_position)

  #   Buffer.modify(state.active_buffer, {:insert, "\n", cursor_pos})

  #   state |> OmegaState.add_to_history(input)
  # end

  # def handle_input(%OmegaState{mode: mode} = state, @escape_key) when mode in [:command, :insert] do
  #   Flamelex.API.CommandBuffer.deactivate()
  #   Flamelex.OmegaMaster.switch_mode(:normal)
  #   state |> OmegaState.set(mode: :normal)
  # end

  # def handle_input(%Flamelex.Structs.OmegaState{mode: :insert} = state, input) when input in @all_letters do
  #   cursor_pos =
  #     {:gui_component, state.active_buffer}
  #     |> ProcessRegistry.find!()
  #     |> GenServer.call(:get_cursor_position)


  #   {:codepoint, {letter, _num}} = input

  #   Buffer.modify(state.active_buffer, {:insert, letter, cursor_pos})

  #   state |> OmegaState.add_to_history(input)
  # end

  # def handle_input(%Flamelex.Structs.OmegaState{mode: :insert} = state, input) do
  #   Logger.debug "received some input whilst in :insert mode"
  #   state |> OmegaState.add_to_history(input)
  # end

end
